//
//  SamplerBroadcaster.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class SamplerBroadcaster {
    let output: MidiOutput

    init(output: MidiOutput){
        self.output = output
    }
}

// MARK: ADDRESSING
extension SamplerBroadcaster {

    private static func channel(cellIndex: Int) -> MidiChannel {
        return cellIndex
    }
}

// MARK: SEND
extension SamplerBroadcaster {

    func broadcast(
        _ parameters: [Cell.Parameter],
        data: SampleCellData,
        cellIndex: Int
    ){
        guard !parameters.isEmpty else { return }
        let midiCCs = SamplerBroadcaster.midiCCs(
            for: parameters,
            data: data,
            channel: SamplerBroadcaster.channel(cellIndex: cellIndex)
        )
        send(midiCCs: midiCCs)
    }

    func broadcastAll(cells: [SampleCellData]){
        let midiCCs = cells.enumerated().flatMap { cellIndex, data in
            SamplerBroadcaster.midiCCs(
                for: Cell.parameters(of: data),
                data: data,
                channel: SamplerBroadcaster.channel(cellIndex: cellIndex)
            )
        }
        send(midiCCs: midiCCs)
    }

    func play(midiNote: MIDINote, cellIndex: Int) throws {
        try output.send(
            midiNote: midiNote,
            channel: SamplerBroadcaster.channel(cellIndex: cellIndex)
        )
    }

    private func send(midiCCs: [MidiControllerChange]){
        do {
            try output.send(midiCCs: midiCCs)
        } catch {
            // print("ERROR SENDING TO SAMPLER: \(error).")
        }
    }
}
