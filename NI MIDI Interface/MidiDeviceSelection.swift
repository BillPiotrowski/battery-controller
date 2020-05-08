//
//  MidiDeviceSelection.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation
import ReactiveSwift


class MidiDeviceSelection {
    private var availableDestinations: [MidiDevice]
    private var selectedDeviceIndex: Int?
    
    private let midiDeviceSelectionInput: Signal<MidiDeviceSelectionStruct, Never>.Observer
    let midiDeviceSelection: Property<MidiDeviceSelectionStruct>
    
    init(midi: MIDI, selectedDeviceIndex: Int?){
        let midiDevices = midi.midiOutputDevices.value
        
        let midiDeviceSelectionSignal = Signal<MidiDeviceSelectionStruct, Never>.pipe()
        let options = MidiDeviceSelection.options(midiDevices: midiDevices)
        let optionIndex = MidiDeviceSelection.optionIndex(selectedDeviceIndex: selectedDeviceIndex)
        let midiDeviceSelection = MidiDeviceSelectionStruct(options: options, selectedIndex: optionIndex)
        
        self.midiDeviceSelectionInput = midiDeviceSelectionSignal.input
        self.midiDeviceSelection = Property(initial: midiDeviceSelection, then: midiDeviceSelectionSignal.output)
        self.availableDestinations = midiDevices
        self.selectedDeviceIndex = selectedDeviceIndex
        
        midi.midiOutputDevices.signal.observe(
            Signal<[MidiDevice], Never>.Observer(
                value: { value in
                    print("NEW MIDI DEVICES RECIEVED!")
                    let currentSelection = value.firstIndex(where: {$0 == self.selectedMidiDevice})
                    self.selectedDeviceIndex = currentSelection
                    self.availableDestinations = value
                    

                    let options = MidiDeviceSelection.options(midiDevices: value)
                    let optionIndex = MidiDeviceSelection.optionIndex(selectedDeviceIndex: currentSelection)
                    
                    let midiDeviceSelection = MidiDeviceSelectionStruct(options: options, selectedIndex: optionIndex)
                    self.midiDeviceSelectionInput.send(value: midiDeviceSelection)
            
        }, failed: {error in}, completed: {}, interrupted: {}))
        
    }
}
extension MidiDeviceSelection {
    static func options(midiDevices: [MidiDevice]) -> [String] {
        var options = ["None"]
        for midiDevice in midiDevices {
            options.append(midiDevice.name)
        }
        return options
    }
    func setDevice(index: Int){
        // Index 0 of string options is "None". This offsets it to match the actual devices options.
        let offsetIndex = index - 1
        guard offsetIndex >= 0
            else {
                selectedDeviceIndex = nil
                return
        }
        selectedDeviceIndex = offsetIndex
        //print("SET DEVICE: \(selectedMidiDevice?.name)")
    }
    static func optionIndex(selectedDeviceIndex: Int?) -> Int {
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return 0 }
        return selectedDeviceIndex + 1
    }
    var selectedMidiDevice: MidiDevice? {
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return nil }
        return availableDestinations[selectedDeviceIndex]
    }
}










