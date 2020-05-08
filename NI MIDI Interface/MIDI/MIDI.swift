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
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(urlContainerDidChange(_:)),
        name: .MIKMIDIVirtualEndpointWasAdded,
        object: MIKMIDIDeviceManager.shared)

        addObserver(self, forKeyPath: #keyPath(MIKDeviceManager.virtualDestinations), options: [.old, .new], context: nil)
        
        //midi.addListener(self)
        
    }
    @objc func urlContainerDidChange(_ test: NSNotification){
        //print("CHANGED!!!!!!")
        //dump(test.userInfo)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //dump(object)
        if keyPath == #keyPath(MIKDeviceManager.virtualDestinations) {
            // Update Time Label
            /*
            print("VIRTUAL DEST CHANGED!")
            for virtualDevice in MIKDeviceManager.virtualDestinations {
                print(virtualDevice.name ?? "UNKNOWN")
                print(virtualDevice)
            }
 */
            let outputDevices = MIDI.getOutputDevices(
                deviceManager: MIKDeviceManager
            )
            self.midiOutputDevicesInput.send(value: outputDevices)
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
    
    func connect(midiSource: MidiSource, eventHandler: @escaping (MidiSource, [MidiCommand]) -> Void) throws -> Any {
        return try self.MIKDeviceManager.connectInput(midiSource.mikEndpoint, eventHandler: { mikMidiSource, mikMidiCommands in
            let midiSource = MidiSource(mikMidiSourceEndpoint: mikMidiSource)
            var midiCommands = [MidiCommand]()
            for mikMidiCommand in mikMidiCommands {
                let midiCommand = MidiCommand(mikMidiCommand: mikMidiCommand)
                midiCommands.append(midiCommand)
            }
            eventHandler(midiSource, midiCommands)
            
        })
        
        /*
        let signalProducer: SignalProducer<Int, Never> =
         SignalProducer { (observer, lifetime) in
            for i in 0..<10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
              observer.send(value: i)
              if i == 9 { //Mark completion on 9th iteration
                observer.sendCompleted()
              }
            }
          }
        }
 */
    }
    
    
    
    
}
/*
extension MIDI: AKMIDIListener{
    func receivedMIDINoteOn(
        noteNumber: MIDINoteNumber,
        velocity: MIDIVelocity,
        channel: MIDIChannel,
        portID: MIDIUniqueID?,
        offset: MIDITimeStamp
    ){
        
        //print("NOTE ON: \(noteNumber) / VEL: \(velocity), port: \(portID)")
        let midiNote = MIDINote(noteNumber: Int(noteNumber), velocity: Int(velocity))
        midiNoteInput.send(value: midiNote)
    }
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
        print("NOTE OFF")
        
    }
    func receivedMIDIController(
        _ controller: MIDIByte,
        value: MIDIByte,
        channel: MIDIChannel,
        portID: MIDIUniqueID?,
        offset: MIDITimeStamp
    ){
        let midiCC = MidiControllerChange(
            ccNumber: MidiControlChangeNumber(controller),
            value: Int(value),
            channel: MidiChannel(channel)
        )
        midiCCInput.send(value: midiCC)
    }
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
        
    }
    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
        
    }
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
        
    }
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
        
    }
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp){
        
    }
    
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification){
        /*
        switch propertyChangeInfo.messageID {
        case .msgObjectAdded:
            print("OBJECT ADDED!")
            print("OBJECT TYPE: \(propertyChangeInfo.objectType)")
            print("OBJECT: \(propertyChangeInfo.object)")
        case .msgObjectRemoved:
            print("OBJECT REMOVED!")
            print("OBJECT TYPE: \(propertyChangeInfo.objectType)")
            print("OBJECT: \(propertyChangeInfo.object)")
        case .msgIOError: print("IO ERROR")
        case .msgPropertyChanged:
            print("MIDI PROPERTY CHANGE!")
            // DOES NOT WORK. NEED TO FIGURE OUT!!!!!
            let object = propertyChangeInfo.object
            
            var unmanagedProperties: Unmanaged<CFPropertyList>?

            MIDIObjectGetProperties(object, &unmanagedProperties, true)
            
            guard let properties = unmanagedProperties?.takeUnretainedValue() as? [String: Any]
                else {
                    unmanagedProperties?.release()
                    break
            }
            /*
            for property in properties {
                print(property)
            }
            */
            guard let uniqueID = properties["uniqueID"] as? Int32
                else { break }
            //print("PRE COUNT: \(midi.destinationUIDs)")
            
            midi.createVirtualOutputPort(uniqueID, name: "NEW PORT")
            midi.createVirtualInputPort(uniqueID, name: "NEW PORT")
            //print("DESTINATION NAME: \(midi.destinationName(for: uniqueID))")
            
            //print("POST COUNT: \(midi.destinationUIDs)")
            //print("SOURCE COUNT: \(midi.inputUIDs)")
            
            
            
        case .msgSerialPortOwnerChanged: print("PORT OWNER CHANGED")
        case .msgSetupChanged: print("SETUP CHANGED")
        case .msgThruConnectionsChanged: print("THRU CONNECTION CHANGED")
        default: break
        }
        
        let newOutputDevices = MIDI.getOutputDevices(midi: midi)
        if(midiOutputDevices.value != newOutputDevices) {
            print("NEW OUTPUT DEVICES")
            midiOutputDevicesInput.send(value: newOutputDevices)
        }
 */
    }
    func receivedMIDINotification(notification: MIDINotification){
        
        /*
        switch notification.messageID{
        case .msgObjectAdded: print("OBJECT ADDED")
        case .msgObjectRemoved: print("OBJECT REMOVED")
        default: break
        }
 */
    }
}

*/


extension MIDI {
    func sendMidiNote(midiNote: MIDINote, channel: Int, devices: [MidiDevice]) throws {
        print("CHANNEL: \(channel)")
        
        let midiNoteCommand = MIKMIDINoteCommand(
            note: UInt(midiNote.noteNumber),
            velocity: UInt(midiNote.velocity),
            channel: UInt8(channel),
            isNoteOn: true,
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
