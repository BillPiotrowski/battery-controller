//
//  MidiDeviceSelection.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation
import ReactiveSwift


class MidiOutput {
    private var availableDestinations: [MidiDevice]
    //private var selectedDeviceIndex: Int?
    private var selectedUIDs: [Int32]
    private let midi: MIDI
    
    private let midiDeviceSelectionInput: Signal<[MidiOutputInfo], Never>.Observer
    let midiDeviceSelection: Property<[MidiOutputInfo]>
    
    init(midi: MIDI, selectedDeviceIndex: Int?){
        let midiDevices = midi.midiOutputDevices.value
        let selectedUIDs = [Int32]()
        
        let midiDeviceSelectionSignal = Signal<[MidiOutputInfo], Never>.pipe()
        let options = MidiOutput.options(midiDevices: midiDevices)
        let optionIndex = MidiOutput.optionIndex(selectedDeviceIndex: selectedDeviceIndex)
        let midiDeviceSelection = MidiOutput.getMidiInputInfoArray(availableDestinations: midiDevices, selectedUIDs: selectedUIDs)
        
        self.midiDeviceSelectionInput = midiDeviceSelectionSignal.input
        self.midiDeviceSelection = Property(initial: midiDeviceSelection, then: midiDeviceSelectionSignal.output)
        self.availableDestinations = midiDevices
        //self.selectedDeviceIndex = selectedDeviceIndex
        self.selectedUIDs = selectedUIDs
        self.midi = midi
        
        midi.midiOutputDevices.signal.observe(
            Signal<[MidiDevice], Never>.Observer(
                value: { value in
                    print("NEW MIDI DEVICES RECIEVED!")
                    //let currentSelection = value.firstIndex(where: {$0 == self.selectedMidiDevice})
                    //self.selectedDeviceIndex = currentSelection
                    
                    let deviceInfo = MidiOutput.getMidiInputInfoArray(
                        availableDestinations: value,
                        selectedUIDs: self.selectedUIDs
                    )
                    
                    self.availableDestinations = value
                    self.midiDeviceSelectionInput.send(value: deviceInfo)
            
        }, failed: {error in}, completed: {}, interrupted: {}))
        
    }
}
extension MidiOutput {
    static func options(midiDevices: [MidiDevice]) -> [String] {
        var options = ["None"]
        for midiDevice in midiDevices {
            options.append(midiDevice.name)
        }
        return options
    }
    
    func setDevice(index: Int){
        // Index 0 of string options is "None". This offsets it to match the actual devices options.
        let destination = availableDestinations[index]
        self.selectedUIDs.append(destination.mikEndpoint.uniqueID)
        
        //selectedDeviceIndex = offsetIndex
        //print("SET DEVICE: \(selectedMidiDevice?.name)")

        let deviceInfo = MidiOutput.getMidiInputInfoArray(
            availableDestinations: self.availableDestinations,
            selectedUIDs: self.selectedUIDs
        )
        self.midiDeviceSelectionInput.send(value: deviceInfo)
    }
    func disconnect(midiOutputInfo: MidiOutputInfo){
        self.selectedUIDs.removeAll(where: { $0 == midiOutputInfo.midiDestination.mikEndpoint.uniqueID })
        let deviceInfo = MidiOutput.getMidiInputInfoArray(
            availableDestinations: self.availableDestinations,
            selectedUIDs: self.selectedUIDs
        )
        self.midiDeviceSelectionInput.send(value: deviceInfo)
    }
    static func optionIndex(selectedDeviceIndex: Int?) -> Int {
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return 0 }
        return selectedDeviceIndex + 1
    }
    var selectedMidiDevices: [MidiDevice] {
        var midiDevices = [MidiDevice]()
        for uid in selectedUIDs {
            guard
                let device = availableDestinations.first(
                    where: {$0.mikEndpoint.uniqueID == uid}
                )
                else {
                    print("ERROR: Device missing. UID: \(uid)")
                    continue
            }
            midiDevices.append(device)
        }
        return midiDevices
        /*
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return nil }
        return availableDestinations[selectedDeviceIndex]
 */
    }
}


extension MidiOutput {
    func send(midiCC: MidiControllerChange) throws {
        try self.midi.send(midiCC: midiCC, devices: selectedMidiDevices)
    }
    func send(midiCCs: [MidiControllerChange]) throws {
        print(midiCCs)
        try self.midi.send(midiCCs: midiCCs, devices: selectedMidiDevices)
    }
    func send(
        midiNote: MIDINote,
        channel: Int
    ) throws {
        try midi.sendMidiNote(
            midiNote: midiNote,
            channel: channel,
            devices: selectedMidiDevices
        )
    }
}


extension MidiOutput {
    
    private func getMidiInputInfoArray() -> [MidiOutputInfo] {
        return MidiOutput.getMidiInputInfoArray(
            availableDestinations: self.availableDestinations,
            selectedUIDs: self.selectedUIDs
        )
    }
    
    static func getMidiInputInfoArray(
        availableDestinations: [MidiDevice],
        selectedUIDs: [Int32]
    ) -> [MidiOutputInfo] {
        var devices = [MidiOutputInfo]()
        for midiDestination in availableDestinations {
            let uid = midiDestination.mikEndpoint.uniqueID
            let active = MidiOutput.isActive(
                uid: uid,
                selectedUIDs: selectedUIDs
            )
            let device = MidiOutputInfo(midiDestination: midiDestination, active: active)
            devices.append(device)
        }
        return devices
    }
    
    static func isActive(uid: Int32, selectedUIDs: [Int32]) -> Bool {
        return selectedUIDs.contains(uid)
    }
    func isActive(uid: Int32) -> Bool {
        return MidiOutput.isActive(
            uid: uid,
            selectedUIDs: self.selectedUIDs
        )
    }
}

