//
//  MIDI.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

//import Foundation
//import AudioKit
import ReactiveSwift
//import CoreMIDI
import MIKMIDI

struct MIDINote {
    // use type alias?
    let noteNumber: CustomMIDINoteNumber
    let velocity: Int
    let isNoteOn: Bool
}


class MIDI: NSObject {
    //private let midi: AKMIDI
    //var outputDevices: [MidiDevice] = []
    /*
    var  portRef: MIDIPortRef {
        return midi.outputPort
    }
    */
    private var token: Any?
    @objc dynamic let MIKDeviceManager: MIKMIDIDeviceManager
    
    let midiNoteObserver: Signal<MIDINote, Never>
    private let midiNoteInput: Signal<MIDINote, Never>.Observer
    
    let midiCCObserver: Signal<MidiControllerChange, Never>
    private let midiCCInput: Signal<MidiControllerChange, Never>.Observer
    
    private let midiOutputDevicesInput: Signal<[MidiDevice], Never>.Observer
    let midiOutputDevices: Property<[MidiDevice]>
    
    private let midiSourcesInput: Signal<[MidiSource], Never>.Observer
    let midiSources: Property<[MidiSource]>
    
    
    override init(){
        //let midi = AudioKit.midi
        let midiNoteSignal = Signal<MIDINote, Never>.pipe()
        let midiCCSignal = Signal<MidiControllerChange, Never>.pipe()
        let midiOutputDeviceSignal = Signal<[MidiDevice], Never>.pipe()
        let midiSources = Signal<[MidiSource], Never>.pipe()
        
        //midi.openInput()
        //midi.openOutput()
        
        let deviceManager = MIKMIDIDeviceManager.shared
        
        let outputDevices = MIDI.getOutputDevices(
            deviceManager: deviceManager
        )
        
        let sourceDevices = MIDI.getSources(deviceManager: deviceManager)
        
        
        print()
        
        self.MIKDeviceManager = deviceManager
        //self.midi = midi
        self.midiNoteInput = midiNoteSignal.input
        self.midiNoteObserver = midiNoteSignal.output
        self.midiCCInput = midiCCSignal.input
        self.midiCCObserver = midiCCSignal.output
        self.midiOutputDevicesInput = midiOutputDeviceSignal.input
        self.midiOutputDevices = Property(initial: outputDevices, then: midiOutputDeviceSignal.output)
        self.midiSourcesInput = midiSources.input
        self.midiSources = Property(initial: sourceDevices, then: midiSources.output)
        super.init()
        //midi.createVirtualInputPort(98909, name: "NI Interface")
        //print(midi.virtualInput)
        
        //self.outputDevices = MIDI.getOutputDevices(midi: midi)
        
        
        //let allDevices = MIKMIDIDeviceManager.shared.virtualDestinations
        print("ALL DEVICES:")
        print(MIKDeviceManager.virtualDestinations)
        /*
        NotificationCenter.default.addObserver(self,
        selector: #selector(urlContainerDidChange(_:)),
        name: .MIKMIDIVirtualEndpointWasAdded,
        object: MIKMIDIDeviceManager.shared)
*/
        addObserver(
            self,
            forKeyPath: #keyPath(MIKDeviceManager.virtualDestinations),
            options: [.old, .new],
            context: nil
        )
        addObserver(
            self,
            forKeyPath: #keyPath(MIKDeviceManager.virtualSources),
            options: [.old, .new],
            context: nil
        )
        
        
        
    }
    @objc func urlContainerDidChange(_ test: NSNotification){
        //print("CHANGED!!!!!!")
        //dump(test.userInfo)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(MIKDeviceManager.virtualDestinations) {
            let outputDevices = MIDI.getOutputDevices(
                deviceManager: MIKDeviceManager
            )
            self.midiOutputDevicesInput.send(value: outputDevices)
        }
        if keyPath == #keyPath(MIKDeviceManager.virtualSources) {
            let inputDevices = MIDI.getSources(
                deviceManager: MIKDeviceManager
            )
            self.midiSourcesInput.send(value: inputDevices)
        }
        
    }
    
    private static func getOutputDevices(
        deviceManager: MIKMIDIDeviceManager
    ) -> [MidiDevice]{
        var outputDevices = [MidiDevice]()
        for virtualDestination in deviceManager.virtualDestinations {
            let outputDevice = MidiDevice(
                virtualDestination: virtualDestination
            )
            outputDevices.append(outputDevice)
        }
        return outputDevices
    }
    private static func getSources (
        deviceManager: MIKMIDIDeviceManager
    ) -> [MidiSource]{
        var sources = [MidiSource]()
        for virtualSource in deviceManager.virtualSources {
            let source = MidiSource(
                mikMidiSourceEndpoint: virtualSource
            )
            sources.append(source)
        }
        return sources
    }
    
    func connect(
        midiSource: MidiSource,
        eventHandler: @escaping (MidiSource, [MidiCommand]) -> Void
    ) throws -> Any {
        print("DEVICES")
        print(MIKMIDIDeviceManager.shared.availableDevices)
        let token = try MIKMIDIDeviceManager.shared.connectInput(
            midiSource.mikEndpoint,
            //eventHandler: <#T##MIKMIDIEventHandlerBlock##MIKMIDIEventHandlerBlock##(MIKMIDISourceEndpoint, [MIKMIDICommand]) -> Void#>)
        //return try self.MIKDeviceManager.connectInput(
          //  midiSource.mikEndpoint,
            eventHandler: { mikMidiSource, mikMidiCommands in
                //print("mIDI EVENT")
                let midiSource = MidiSource(mikMidiSourceEndpoint: mikMidiSource)
                var midiCommands = [MidiCommand]()
                for mikMidiCommand in mikMidiCommands {
                    let midiCommand = MidiCommand(mikMidiCommand: mikMidiCommand)
                    midiCommands.append(midiCommand)
                }
                eventHandler(midiSource, midiCommands)
                
            }
        )
        return token
    }
    // DISCONNECT DOES NOT APPEAR TO BE WORKING!!
    // BUG: https://github.com/mixedinkey-opensource/MIKMIDI/issues/289
    func disconnect(token: Any){
        MIKMIDIDeviceManager.shared.disconnectConnection(forToken: token)
    }
    
    
    
    
}


extension MIDI {
    func sendMidiNote(midiNote: MIDINote, channel: Int, devices: [MidiDevice]) throws {
        //print("CHANNEL: \(channel)")
        
        let midiNoteCommand = MIKMIDINoteCommand(
            note: UInt(midiNote.noteNumber),
            velocity: UInt(midiNote.velocity),
            channel: UInt8(channel),
            isNoteOn: midiNote.isNoteOn,
            midiTimeStamp: MIDITimeStamp()
        )
        for device in devices {
            try MIKDeviceManager.send(
                [midiNoteCommand],
                to: device.mikEndpoint
            )
        }
    }
    func send(midiCC: MidiControllerChange, devices: [MidiDevice]) throws {
        let midiCommand = MIKMutableMIDIControlChangeCommand(
            controllerNumber: UInt(midiCC.ccNumber),
            value: UInt(midiCC.value)
        )
        midiCommand.channel = UInt8(midiCC.channel)
        for device in devices {
            try MIKDeviceManager.send([midiCommand], to: device.mikEndpoint)
        }
        
        
        
        
        // SAVE SOME OF THIS. A LOT OF WORK WENT INTO STARTING TO FIGURE OUT HOW TO INTEGRATE OBJ C
        
        /*
        guard
            let destinationDevices = midiCC.destinationDevices,
            destinationDevices.count > 0
            else {
                print("bad")
                return
        }
        let midiEndpoint = destinationDevices[0].midiEndpointRef
        
        
        var pkt = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        let pktList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        pkt = MIDIPacketListInit(pktList)
        pkt = MIDIPacketListAdd(pktList, 1024, pkt, 0, 3, midiCC.midiData)
        print("SENDING: \(destinationDevices[0].name)")
        
        MIDISend(self.portRef, midiEndpoint, pktList)
        */
    }
    func send(midiCCs: [MidiControllerChange], devices: [MidiDevice]) throws {
        for midiCC in midiCCs {
            try send(midiCC: midiCC, devices: devices)
        }
    }
}


struct MidiCommand {
    let mikMidiCommand: MIKMIDICommand
}
