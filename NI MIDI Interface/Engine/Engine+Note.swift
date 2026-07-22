//
//  Engine+Note.swift
//  NI MIDI Interface
//
//  Created by Bill Piotrowski on 7/22/26.
//  Copyright © 2026 William Piotrowski. All rights reserved.
//

import Foundation

// MARK: MIDI NOTE CHANGE
extension Engine {
    func midiKeyboardNoteHandler(midiNote: MIDINote){
        samplerBroadcaster.play(
            midiNote: midiNote,
            cellIndex: kit.editingCellIndex
        )
    }
    func midiNoteHandler(midiNote: MIDINote){
        let isNoteOn = midiNote.velocity > 0 && midiNote.isNoteOn
        guard let cellIndex = midiNote.cellIndex
            else {
                print("No cell index.")
                return
        }
        if isNoteOn {
            if kit.setEditingCellIndex(cellIndex) {
                updateController()
            }
        }
        guard kit.isPlayable(cellIndex: cellIndex)
            else {
                print("CAN NOT PLAY")
                return
        }
        let pitch = kit.sampleCellData(cellIndex: cellIndex).sampleData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: isNoteOn
        )
        samplerBroadcaster.play(
            midiNote: newMidiNote,
            cellIndex: cellIndex
        )
    }
}
