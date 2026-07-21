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
