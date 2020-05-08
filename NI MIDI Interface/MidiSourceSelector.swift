//
//  MidiSourceSelector.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/7/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import ReactiveSwift
import MIKMIDI

// MARK: INPUT

class MidiInput {
    private var midiSources: [MidiSource]
    private var selectedDeviceIndex: Int?
    private let midi: MIDI
    
    let midiNoteObserver: Signal<MIDINote, Never>
    private let midiNoteInput: Signal<MIDINote, Never>.Observer
    
    let midiCCObserver: Signal<MidiControllerChange, Never>
    private let midiCCInput: Signal<MidiControllerChange, Never>.Observer
    
    
    
    
    
    private let midiSourceSelectionInput: Signal<MidiSourceSelectionStruct, Never>.Observer
    let midiSourceSelection: Property<MidiSourceSelectionStruct>
    
    init(midi: MIDI, selectedDeviceIndex: Int?){
        let midiSources = midi.midiSources.value
        let options = MidiInput.options(midiSources: midiSources)
        
        let midiNoteSignal = Signal<MIDINote, Never>.pipe()
        let midiCCSignal = Signal<MidiControllerChange, Never>.pipe()
        
        let midiSourceSelectionSignal = Signal<MidiSourceSelectionStruct, Never>.pipe()
        let optionIndex = MidiInput.optionIndex(selectedDeviceIndex: selectedDeviceIndex)
        let midiSourceSelection = MidiSourceSelectionStruct(options: options, selectedIndices: [optionIndex])
        
        self.midiNoteInput = midiNoteSignal.input
        self.midiNoteObserver = midiNoteSignal.output
        self.midiCCInput = midiCCSignal.input
        self.midiCCObserver = midiCCSignal.output
        self.midiSourceSelectionInput = midiSourceSelectionSignal.input
        self.midiSourceSelection = Property(initial: midiSourceSelection, then: midiSourceSelectionSignal.output)
        self.midiSources = midiSources
        self.selectedDeviceIndex = selectedDeviceIndex
        self.midi = midi
        
        midi.midiSources.signal.observe(
            Signal<[MidiSource], Never>.Observer(
                value: { value in
                    print("NEW MIDI DEVICES RECIEVED!")
                    //let currentSelection: Int?
                    //if let selectedMidiSource = self.selectedMidiSource {
                        let currentSelection = value.firstIndex(where: {$0 == self.selectedMidiSource})
                    //} else {
                    //    currentSelection = nil
                    //}
                    self.selectedDeviceIndex = currentSelection
                    self.midiSources = value
                    

                    let options = MidiInput.options(midiSources: value)
                    let optionIndex = MidiInput.optionIndex(selectedDeviceIndex: currentSelection)
                    
                    let midiDeviceSelection = MidiSourceSelectionStruct(options: options, selectedIndices: [optionIndex])
                    self.midiSourceSelectionInput.send(value: midiDeviceSelection)
            
        }, failed: {error in}, completed: {}, interrupted: {}))
        
    }
}
extension MidiInput {
    static func options(midiSources: [MidiSource]) -> [String] {
        var options = ["None"]
        for midiSource in midiSources {
            options.append(midiSource.name)
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
        let struc = MidiSourceSelectionStruct(options: midiSourceSelection.value.options, selectedIndices: [offsetIndex])
        midiSourceSelectionInput.send(value: struc)
        //print("SET DEVICE: \(selectedMidiDevice?.name)")
        guard let selectedMidiSource = selectedMidiSource
            else {
                print("NO SOURCE")
                return
        }
        do {
            let token = try midi.connect(midiSource: selectedMidiSource, eventHandler: { midiSource, midiCommands in
                
                for midiCommand in midiCommands {
                    switch midiCommand.mikMidiCommand.commandType {
                    case .noteOn, .noteOff:
                        print("NOTE!!")
                        guard let mikMidiNote = midiCommand.mikMidiCommand as? MIKMIDINoteCommand
                        //guard let mikMidiNote = midiCommand.mikMidiCommand as? MIKMIDINoteOnCommand
                            else {
                                print("NOT A MIDI NOTE ON")
                                return
                        }
                        //let isNoteOn = (mikMidiNote.velocity > 0)
                        let midiNote = MIDINote(noteNumber: Int(mikMidiNote.note), velocity: Int(mikMidiNote.velocity), isNoteOn: mikMidiNote.isNoteOn)
                        self.midiNoteInput.send(value: midiNote)
                        /*
                    case .noteOff:
                        guard let mikMidiNote = midiCommand.mikMidiCommand as? MIKMIDINoteOffCommand
                            else {
                                print("NOT A MIDI NOTE ON")
                                return
                        }
 */
                    case .controlChange:
                        guard let mikCommandChange = midiCommand.mikMidiCommand as? MIKMIDIControlChangeCommand
                            else {
                                print("NOT A MIDI CC")
                                return
                        }
                        let midiCC = MidiControllerChange(ccNumber: MidiControlChangeNumber(mikCommandChange.controllerNumber), value: MidiControlChangeValue(mikCommandChange.controllerValue), channel: MidiChannel(mikCommandChange.channel))
                        self.midiCCInput.send(value: midiCC)
                    default: break
                    }
                }
                
            })
            print("CONNECT!")
        } catch {
            print(error)
        }
    }
    static func optionIndex(selectedDeviceIndex: Int?) -> Int {
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return 0 }
        return selectedDeviceIndex + 1
    }
    var selectedMidiSource: MidiSource? {
        guard let selectedDeviceIndex = selectedDeviceIndex
            else { return nil }
        return midiSources[selectedDeviceIndex]
    }
}


struct MidiSourceSelectionStruct {
    let options: [String]
    let selectedIndices: [Int]
}
