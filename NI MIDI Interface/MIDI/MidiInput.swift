//
//  MidiSourceSelector.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/7/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import CoreMIDI
import ReactiveSwift

class MidiInput {
    private var availableSources: [MidiSource]
    private let midi: MIDI
    private var selectedSourceIDs: Set<MIDIUniqueID>

    let midiNoteObserver: Signal<MIDINote, Never>
    private let midiNoteInput: Signal<MIDINote, Never>.Observer

    let midiCCObserver: Signal<MidiControllerChange, Never>
    private let midiCCInput: Signal<MidiControllerChange, Never>.Observer

    private let optionsInput: Signal<[MidiInputInfo], Never>.Observer
    let options: Property<[MidiInputInfo]>

    init(midi: MIDI, selectedDeviceIndex: Int?){
        let midiSources = midi.midiSources.value
        let selectedSourceIDs = Set<MIDIUniqueID>()

        let midiNoteSignal = Signal<MIDINote, Never>.pipe()
        let midiCCSignal = Signal<MidiControllerChange, Never>.pipe()

        let midiSourceSelectionSignal = Signal<[MidiInputInfo], Never>.pipe()
        let midiSourceSelection = MidiInput.getMidiInputInfoArray(availableSources: midiSources, selectedSourceIDs: selectedSourceIDs)

        self.midiNoteInput = midiNoteSignal.input
        self.midiNoteObserver = midiNoteSignal.output
        self.midiCCInput = midiCCSignal.input
        self.midiCCObserver = midiCCSignal.output
        self.optionsInput = midiSourceSelectionSignal.input
        self.options = Property(initial: midiSourceSelection, then: midiSourceSelectionSignal.output)
        self.availableSources = midiSources
        self.midi = midi
        self.selectedSourceIDs = selectedSourceIDs

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
            selectedSourceIDs: self.selectedSourceIDs
        )

        self.availableSources = midiSources
        self.optionsInput.send(
            value: midiDeviceSelection
        )
    }

    private func midiEventHandler(events: [MidiEvent]){
        for event in events {
            switch event {
            case .note(let midiNote):
                self.midiNoteInput.send(value: midiNote)
            case .controlChange(let midiCC):
                self.midiCCInput.send(value: midiCC)
            }
        }
    }
}

// MARK: PUBLIC METHODS
extension MidiInput {
    func connect(input: MidiInputInfo) throws {
        try midi.connect(
            midiSource: input.midiSource,
            eventHandler: self.midiEventHandler(events:)
        )
        selectedSourceIDs.insert(input.midiSource.uniqueID)
    }
    func disconnect(input: MidiInputInfo){
        midi.disconnect(midiSource: input.midiSource)
        selectedSourceIDs.remove(input.midiSource.uniqueID)
    }
}


extension MidiInput {
    private func getMidiInputInfoArray() -> [MidiInputInfo] {
        return MidiInput.getMidiInputInfoArray(
            availableSources: self.availableSources,
            selectedSourceIDs: self.selectedSourceIDs
        )
    }

    static func getMidiInputInfoArray(
        availableSources: [MidiSource],
        selectedSourceIDs: Set<MIDIUniqueID>
    ) -> [MidiInputInfo] {
        var devices = [MidiInputInfo]()
        for midiSource in availableSources {
            let active = MidiInput.isActive(
                uid: midiSource.uniqueID,
                selectedSourceIDs: selectedSourceIDs
            )
            let device = MidiInputInfo(midiSource: midiSource, active: active)
            devices.append(device)
        }
        return devices
    }

    static func isActive(uid: MIDIUniqueID, selectedSourceIDs: Set<MIDIUniqueID>) -> Bool {
        return selectedSourceIDs.contains(uid)
    }
    func isActive(uid: MIDIUniqueID) -> Bool {
        return MidiInput.isActive(
            uid: uid,
            selectedSourceIDs: self.selectedSourceIDs
        )
    }
}
