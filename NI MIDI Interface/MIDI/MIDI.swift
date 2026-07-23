//
//  MIDI.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import CoreMIDI
import Foundation
import ReactiveSwift

struct MIDINote {
    let noteNumber: CustomMIDINoteNumber
    let velocity: Int
    let isNoteOn: Bool
}

enum MidiEvent {
    case note(MIDINote)
    case controlChange(MidiControllerChange)
}

class MIDI {
    private var client = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var outputPort = MIDIPortRef()

    private let midiOutputDevicesInput: Signal<[MidiDevice], Never>.Observer
    let midiOutputDevices: Property<[MidiDevice]>

    private let midiSourcesInput: Signal<[MidiSource], Never>.Observer
    let midiSources: Property<[MidiSource]>

    // Keyed by the connected source's uniqueID. Lets the single shared input
    // port fan packets back out to whichever MidiInput registered that source.
    private var connections: [MIDIUniqueID: ([MidiEvent]) -> Void] = [:]

    init() {
        let midiOutputDeviceSignal = Signal<[MidiDevice], Never>.pipe()
        let midiSourceSignal = Signal<[MidiSource], Never>.pipe()

        self.midiOutputDevicesInput = midiOutputDeviceSignal.input
        self.midiSourcesInput = midiSourceSignal.input

        let outputDevices = MIDI.getOutputDevices()
        let sources = MIDI.getSources()

        self.midiOutputDevices = Property(initial: outputDevices, then: midiOutputDeviceSignal.output)
        self.midiSources = Property(initial: sources, then: midiSourceSignal.output)

        MIDIClientCreateWithBlock("NI MIDI Interface" as CFString, &client) { [weak self] notification in
            self?.handleMIDINotification(notification)
        }
        MIDIInputPortCreateWithBlock(client, "NI MIDI Interface Input" as CFString, &inputPort) { [weak self] packetList, connRefCon in
            self?.handle(packetList: packetList, connRefCon: connRefCon)
        }
        MIDIOutputPortCreate(client, "NI MIDI Interface Output" as CFString, &outputPort)
    }

    deinit {
        MIDIClientDispose(client)
    }
}

// MARK: DEVICE LIST
extension MIDI {
    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgObjectAdded, .msgObjectRemoved, .msgSetupChanged:
            DispatchQueue.main.async { [weak self] in
                self?.refreshDevices()
            }
        default:
            break
        }
    }

    private func refreshDevices() {
        let outputDevices = MIDI.getOutputDevices()
        midiOutputDevicesInput.send(value: outputDevices)

        let sources = MIDI.getSources()
        midiSourcesInput.send(value: sources)

        // Drop bookkeeping for any source that disappeared out from under us.
        let currentSourceIDs = Set(sources.map { $0.uniqueID })
        for uniqueID in connections.keys where !currentSourceIDs.contains(uniqueID) {
            connections.removeValue(forKey: uniqueID)
        }
    }

    private static func getOutputDevices() -> [MidiDevice] {
        var devices = [MidiDevice]()
        for i in 0..<MIDIGetNumberOfDestinations() {
            let endpoint = MIDIGetDestination(i)
            guard let uniqueID = endpointUniqueID(endpoint) else { continue }
            devices.append(MidiDevice(endpointRef: endpoint, uniqueID: uniqueID, name: endpointName(endpoint)))
        }
        return devices
    }

    private static func getSources() -> [MidiSource] {
        var sources = [MidiSource]()
        for i in 0..<MIDIGetNumberOfSources() {
            let endpoint = MIDIGetSource(i)
            guard let uniqueID = endpointUniqueID(endpoint) else { continue }
            sources.append(MidiSource(endpointRef: endpoint, uniqueID: uniqueID, name: endpointName(endpoint)))
        }
        return sources
    }

    private static func endpointUniqueID(_ endpoint: MIDIEndpointRef) -> MIDIUniqueID? {
        var uniqueID: MIDIUniqueID = 0
        guard MIDIObjectGetIntegerProperty(endpoint, kMIDIPropertyUniqueID, &uniqueID) == noErr else { return nil }
        return uniqueID
    }

    private static func endpointName(_ endpoint: MIDIObjectRef) -> String {
        var name: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
        return name?.takeRetainedValue() as String? ?? "Unknown"
    }
}

// MARK: CONNECT / DISCONNECT
extension MIDI {
    func connect(
        midiSource: MidiSource,
        eventHandler: @escaping ([MidiEvent]) -> Void
    ) throws {
        let status = MIDIPortConnectSource(inputPort, midiSource.endpointRef, MIDI.connRefCon(for: midiSource.uniqueID))
        guard status == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
        connections[midiSource.uniqueID] = eventHandler
    }

    func disconnect(midiSource: MidiSource) {
        MIDIPortDisconnectSource(inputPort, midiSource.endpointRef)
        connections.removeValue(forKey: midiSource.uniqueID)
    }

    private static func connRefCon(for uniqueID: MIDIUniqueID) -> UnsafeMutableRawPointer? {
        UnsafeMutableRawPointer(bitPattern: Int(uniqueID))
    }

    private static func uniqueID(from connRefCon: UnsafeMutableRawPointer?) -> MIDIUniqueID? {
        guard let connRefCon = connRefCon else { return nil }
        return MIDIUniqueID(Int(bitPattern: connRefCon))
    }
}

// MARK: RECEIVE
extension MIDI {
    private func handle(packetList: UnsafePointer<MIDIPacketList>, connRefCon: UnsafeMutableRawPointer?) {
        guard
            let uniqueID = MIDI.uniqueID(from: connRefCon),
            let eventHandler = connections[uniqueID]
        else { return }

        let events = MIDI.parseEvents(from: packetList)
        guard !events.isEmpty else { return }
        eventHandler(events)
    }

    private static func parseEvents(from packetList: UnsafePointer<MIDIPacketList>) -> [MidiEvent] {
        var events = [MidiEvent]()
        var packet = packetList.pointee.packet
        for _ in 0..<packetList.pointee.numPackets {
            if let event = parseEvent(from: packet) {
                events.append(event)
            }
            packet = MIDIPacketNext(&packet).pointee
        }
        return events
    }

    private static func parseEvent(from packet: MIDIPacket) -> MidiEvent? {
        let bytes = Mirror(reflecting: packet.data).children
            .prefix(Int(packet.length))
            .compactMap { $0.value as? UInt8 }

        guard let status = bytes.first else { return nil }
        let type = status & 0xF0
        let channel = Int(status & 0x0F)

        switch type {
        case 0x80 where bytes.count >= 3:
            // Dead branch for Maschine / Controller Editor: it never sends a true
            // Note Off (0x80). Every release arrives as a 0x90 note-on with
            // velocity 0 (handled below).
            return .note(MIDINote(noteNumber: Int(bytes[1]), velocity: Int(bytes[2]), isNoteOn: false))
        case 0x90 where bytes.count >= 3:
            // Velocity 0 collapses to a note-off, so pads MUST be mapped to
            // velocity 1-127. A pad hit with low velovity may read as a note-off
            let velocity = Int(bytes[2])
            return .note(MIDINote(noteNumber: Int(bytes[1]), velocity: velocity, isNoteOn: velocity > 0))
        case 0xB0 where bytes.count >= 3:
            return .controlChange(MidiControllerChange(ccNumber: Int(bytes[1]), value: Int(bytes[2]), channel: channel))
        default:
            return nil
        }
    }
}

// MARK: SEND
extension MIDI {
    func sendMidiNote(midiNote: MIDINote, channel: Int, devices: [MidiDevice]) throws {
        let status: UInt8 = (midiNote.isNoteOn ? 0x90 : 0x80) | UInt8(channel & 0x0F)
        let bytes: [UInt8] = [status, UInt8(clamping: midiNote.noteNumber), UInt8(clamping: midiNote.velocity)]
        try send(bytes: bytes, to: devices)
    }

    func send(midiCC: MidiControllerChange, devices: [MidiDevice]) throws {
        let status: UInt8 = 0xB0 | UInt8(midiCC.channel & 0x0F)
        let bytes: [UInt8] = [status, UInt8(clamping: midiCC.ccNumber), UInt8(clamping: midiCC.value)]
        try send(bytes: bytes, to: devices)
    }

    func send(midiCCs: [MidiControllerChange], devices: [MidiDevice]) throws {
        for midiCC in midiCCs {
            try send(midiCC: midiCC, devices: devices)
        }
    }

    private func send(bytes: [UInt8], to devices: [MidiDevice]) throws {
        guard !devices.isEmpty else { return }

        var sendError: OSStatus = noErr
        var packetList = MIDIPacketList()
        withUnsafeMutablePointer(to: &packetList) { packetListPtr in
            var packet = MIDIPacketListInit(packetListPtr)
            packet = MIDIPacketListAdd(packetListPtr, 1024, packet, 0, bytes.count, bytes)
            for device in devices {
                let status = MIDISend(outputPort, device.endpointRef, packetListPtr)
                if status != noErr { sendError = status }
            }
        }
        guard sendError == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(sendError), userInfo: nil)
        }
    }
}
