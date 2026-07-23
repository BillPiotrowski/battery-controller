//
//  ControllerBroadcaster.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class ControllerBroadcaster {
    let output: MidiOutput

    init(output: MidiOutput){
        self.output = output
    }
}

// MARK: ADDRESSING
extension ControllerBroadcaster {

    static let channel: MidiChannel = 0

    private static func noteNumber(cellIndex: Int) -> Int {
        return MIDINote.noteNumber(cellIndex: cellIndex)
    }
}

// MARK: SEND STATE
// Scoped single-CC pushes for the app-owned toggles. Sending a CC to the
// controller does not loop back, so these light the LED without a full resync.
extension ControllerBroadcaster {
    func sendMute(_ isMuted: Bool){ send(.toggleMute, isMuted) }
    func sendSolo(_ isSoloed: Bool){ send(.toggleSolo, isSoloed) }
    func sendLock(_ isLocked: Bool){ send(.toggleLock, isLocked) }
    func sendTransientMaster(_ isEnabled: Bool){ send(.toggleTransientMaster, isEnabled) }
    func sendLofi(_ isEnabled: Bool){ send(.toggleLofi, isEnabled) }
    func sendAmpEnvelope(_ isEnabled: Bool){ send(.toggleAmpEnvelope, isEnabled) }

    private func send(_ mapping: MidiInputMapping, _ isOn: Bool){
        let midiCC = MidiControllerChange(
            ccNumber: mapping.rawValue,
            value: isOn.MidiCCValue,
            channel: ControllerBroadcaster.channel
        )
        do {
            try output.send(midiCCs: [midiCC])
        } catch {
            print("ERROR SENDING TO CONTROLLER: \(error).")
        }
    }
}

// MARK: SEND
extension ControllerBroadcaster {

    /// Darks every pad, pushes the selected cell's values, then lights its pad.
    func broadcastAll(
        data: SampleCellData,
        selectedCellIndex: Int,
        cellCount: Int
    ){
        let midiCCs = ControllerBroadcaster.midiCCs(for: data)
        do {
            for cellIndex in 0..<cellCount {
                try output.send(
                    midiNote: MIDINote(
                        noteNumber: ControllerBroadcaster.noteNumber(cellIndex: cellIndex),
                        velocity: 0,
                        isNoteOn: false
                    ),
                    channel: ControllerBroadcaster.channel
                )
            }
            try output.send(midiCCs: midiCCs)
            try output.send(
                midiNote: MIDINote(
                    noteNumber: ControllerBroadcaster.noteNumber(cellIndex: selectedCellIndex),
                    velocity: 127,
                    isNoteOn: true
                ),
                channel: ControllerBroadcaster.channel
            )
        } catch {
            print("ERROR SENDING TO CONTROLLER: \(error).")
        }
    }
}

extension Intent {
    /// Indicates that the intent requires a refresh of the controller UI.
    var requiresCompleteControllerRefresh: Bool {
        switch self {
        case .reset, .paste, .resetAll:
            return true
        case .updateCellParameter,
             .unsoloAll, .unlockAll, .lockAll, .undo, .redo,
             .pinSelection, .copy, .mute, .solo, .lock,
             .toggleTransientMaster, .toggleLofi, .toggleAmpEnvelope:
            return false
        }
    }
}
