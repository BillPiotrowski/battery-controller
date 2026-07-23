//
//  MidiSelectionStore.swift
//  NI MIDI Interface
//
//  App-global persistence of the selected MIDI device UIDs, keyed by role.
//  Stored in UserDefaults rather than the document: the MIDI rig belongs to
//  the machine (CoreMIDI uniqueIDs are per-machine), not to a given kit file.
//

import CoreMIDI
import Foundation

enum MidiSelectionRole: String {
    case controllerInput = "midiSelection.controllerInput"
    case controllerOutput = "midiSelection.controllerOutput"
    case samplerOutput = "midiSelection.samplerOutput"
}

struct MidiSelectionStore {
    private let role: MidiSelectionRole
    private let defaults: UserDefaults

    init(role: MidiSelectionRole, defaults: UserDefaults = .standard){
        self.role = role
        self.defaults = defaults
    }

    /// The persisted selection. MIDIUniqueID is Int32; stored as [Int] so it
    /// round-trips cleanly through UserDefaults / NSNumber.
    var uids: [MIDIUniqueID] {
        get {
            let stored = defaults.array(forKey: role.rawValue) as? [Int] ?? []
            return stored.map { MIDIUniqueID(truncatingIfNeeded: $0) }
        }
        nonmutating set {
            defaults.set(newValue.map { Int($0) }, forKey: role.rawValue)
        }
    }
}
