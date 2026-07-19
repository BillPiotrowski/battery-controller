//
//  MidiSourceSelector.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/7/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import ReactiveSwift
import MIKMIDI

class MidiInput {
    private var availableSources: [MidiSource]
    private let midi: MIDI
    private var selectedIndicies: [Int32: Any]
    
    let midiNoteObserver: Signal<MIDINote, Never>
    private let midiNoteInput: Signal<MIDINote, Never>.Observer
    
    let midiCCObserver: Signal<MidiControllerChange, Never>
    private let midiCCInput: Signal<MidiControllerChange, Never>.Observer
    
    private let optionsInput: Signal<[MidiInputInfo], Never>.Observer
    let options: Property<[MidiInputInfo]>
    
    init(midi: MIDI, selectedDeviceIndex: Int?){
        let midiSources = midi.midiSources.value
        let selectedIndices = [Int32: Any]()
        
        let midiNoteSignal = Signal<MIDINote, Never>.pipe()
        let midiCCSignal = Signal<MidiControllerChange, Never>.pipe()
        
        let midiSourceSelectionSignal = Signal<[MidiInputInfo], Never>.pipe()
        let midiSourceSelection = MidiInput.getMidiInputInfoArray(availableSources: midiSources, selectedIndicies: selectedIndices)
        
        self.midiNoteInput = midiNoteSignal.input
        self.midiNoteObserver = midiNoteSignal.output
        self.midiCCInput = midiCCSignal.input
        self.midiCCObserver = midiCCSignal.output
        self.optionsInput = midiSourceSelectionSignal.input
        self.options = Property(initial: midiSourceSelection, then: midiSourceSelectionSignal.output)
        self.availableSources = midiSources
        self.midi = midi
        self.selectedIndicies = selectedIndices
        
        midi.midiSources.signal.observe(
            Signal<[MidiSource], Never>.Observer(
                value: self.midiSourcesObserver(midiSources:)
            )
        )
    }
}

// MARK: PRIVATE METHODS
extension MidiInput {
    private func midiSourcesObserver(midiSources: [MidiSource]){
        let availableSources = midiSources
        let midiDeviceSelection = MidiInput.getMidiInputInfoArray(
            availableSources: availableSources,
            selectedIndicies: self.selectedIndicies
        )
        
        self.availableSources = midiSources
        self.optionsInput.send(
            value: midiDeviceSelection
        )
    }
    
    private func midiEventHandler(
        midiSource: MidiSource,
        midiCommands: [MidiCommand]
    ){
        // WORKAROUND BECAUSE DISCONNECT SEEMS TO BE NOT WORKING!
        guard self.isActive(uid: midiSource.mikEndpoint.uniqueID)
            else {
                print("endpoint not active!")
                return
        }
           for midiCommand in midiCommands {
               switch midiCommand.mikMidiCommand.commandType {
               case .noteOn, .noteOff:
                   //print("NOTE!!")
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
         
                       
    }
}

// MARK: PUBLIC METHODS
extension MidiInput {
    func connect(input: MidiInputInfo) throws {
        let token = try midi.connect(
            midiSource: input.midiSource,
            eventHandler: self.midiEventHandler(midiSource:midiCommands:)
        )
        selectedIndicies[input.midiSource.mikEndpoint.uniqueID] = token
    }
    func disconnect(input: MidiInputInfo){
        let uid = input.midiSource.mikEndpoint.uniqueID
        guard
            let token = selectedIndicies[uid]
            else {
                print("ALREADY DISCONNECTED. No token!")
                return
        }
        midi.disconnect(token: token)
        self.selectedIndicies.removeValue(forKey: uid)
    }
}


extension MidiInput {
    private func getMidiInputInfoArray() -> [MidiInputInfo] {
        return MidiInput.getMidiInputInfoArray(
            availableSources: self.availableSources,
            selectedIndicies: self.selectedIndicies
        )
    }
    
    static func getMidiInputInfoArray(
        availableSources: [MidiSource],
        selectedIndicies: [Int32: Any]
    ) -> [MidiInputInfo] {
        var devices = [MidiInputInfo]()
        for midiSource in availableSources {
            let uid = midiSource.mikEndpoint.uniqueID
            let active = MidiInput.isActive(
                uid: uid,
                selectedIndicies: selectedIndicies
            )
            let device = MidiInputInfo(midiSource: midiSource, active: active)
            devices.append(device)
        }
        return devices
    }
    
    static func isActive(uid: Int32, selectedIndicies: [Int32: Any]) -> Bool {
        return selectedIndicies[uid] != nil
    }
    func isActive(uid: Int32) -> Bool {
        return MidiInput.isActive(
            uid: uid,
            selectedIndicies: self.selectedIndicies
        )
    }
}
