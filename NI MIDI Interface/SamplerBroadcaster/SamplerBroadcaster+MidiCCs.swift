//
//  SamplerBroadcaster+MidiCCs.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

// MARK: ENCODE
extension SamplerBroadcaster {

    /// Encodes cell parameters in to Battery's CC vocabulary.
    ///
    /// Pure by construction: `static`, so it can not reach instance state or send anything. Only the case identity of each parameter is used – every value is read from `data`. That single rule is what lets composites resolve correctly: `speedCoarse` and `speedFine` each need the whole `Speed` to encode, not their own payload.
    ///
    /// - Parameters:
    ///   - parameters: the parameters to encode. Payloads are ignored.
    ///   - data: the cell's current state. The authority for every value, so it must already reflect the change being broadcast.
    ///   - channel: the cell's channel. Battery gives each cell its own.
    /// - Returns: CCs ready to send, deduped by CC number.
    static func midiCCs(
        for parameters: [Cell.Parameter],
        data: SampleCellData,
        channel: MidiChannel
    ) -> [MidiControllerChange] {
        var midiCCs = [MidiControllerChange]()
        var claimedCCNumbers = Set<MidiControlChangeNumber>()

        for parameter in parameters {
            let parameterCCs = SamplerBroadcaster.midiCCs(
                for: parameter,
                data: data,
                channel: channel
            )
            for midiCC in parameterCCs {
                // Values all come from one snapshot, so duplicates are identical
                // and the first is as good as the last. Coarse and fine speed in
                // the same batch is the case that reaches here.
                guard claimedCCNumbers.insert(midiCC.ccNumber).inserted
                    else { continue }
                midiCCs.append(midiCC)
            }
        }
        return midiCCs
    }

    private static func midiCCs(
        for parameter: Cell.Parameter,
        data: SampleCellData,
        channel: MidiChannel
    ) -> [MidiControllerChange] {
        func midiCC(
            _ mapping: MidiOutputMapping,
            _ value: MidiCCValueProtocol
        ) -> [MidiControllerChange] {
            return [
                MidiControllerChange(
                    ccNumber: mapping.rawValue,
                    value: value.MidiCCValue,
                    channel: channel
                )
            ]
        }

        let property = data.propertyData
        let ampEnvelope = data.ampEnvelopeData
        let loFi = data.loFiData

        switch parameter {

        // MARK: Property
        case .start1: return midiCC(.start1, property.start1)
        case .start2: return midiCC(.start2, property.start2)
        case .volume: return midiCC(.volume, property.volume)
        case .pan: return midiCC(.pan, property.pan)
        case .filterLow: return midiCC(.filterLow, property.filterLow)
        case .filterHigh: return midiCC(.filterHigh, property.filterHigh)
        case .transientAttack: return midiCC(.transientAttack, property.transientAttack)
        case .transientSustain: return midiCC(.transientSustain, property.transientSustain)
        case .enableTransientMaster: return midiCC(.enableTransientMaster, property.enableTransientMaster)
        case .fineTune: return midiCC(.fineTune, property.fineTune)
        case .reverbSend: return midiCC(.reverbSend, property.reverbSend)
        case .delaySend: return midiCC(.delaySend, property.delaySend)
        case .velocity: return midiCC(.velocity, property.velocity)
        case .envOrder: return midiCC(.envOrder, property.envOrder)
        case .formant: return midiCC(.formant, property.formant)
        case .loopStart: return midiCC(.loopStart, property.loopStart)
        case .loopStartFine: return midiCC(.loopStartFine, property.loopStartFine)
        case .loopLength: return midiCC(.loopLength, property.loopLength)
        case .loopLengthFine: return midiCC(.loopLengthFine, property.loopLengthFine)

        // MARK: Speed
        // Coarse and fine fold in to a single CC, and the fold decides which of
        // speed1...speed4 it lands on. Both cases therefore emit the same CC and
        // the caller dedupes.
        case .speedCoarse, .speedFine:
            return [property.speed.midiCCs(channel: channel)]

        // MARK: Amp Envelope
        case .attack: return midiCC(.attack, ampEnvelope.attack)
        case .hold: return midiCC(.hold, ampEnvelope.hold)
        case .decay: return midiCC(.decay, ampEnvelope.decay)
        case .sustain: return midiCC(.sustain, ampEnvelope.sustain)
        case .release: return midiCC(.release, ampEnvelope.release)
        case .enableAmpEnvelope: return midiCC(.enableAttackEnvelope, ampEnvelope.enableAmpEnv)

        // MARK: Lo-Fi
        case .lofiBits: return midiCC(.lofiBits, loFi.bits)
        case .lofiHertz: return midiCC(.lofiHertz, loFi.hertz)
        case .lofiNoise: return midiCC(.lofiNoise, loFi.noise)
        case .lofiColor: return midiCC(.lofiColor, loFi.color)
        case .lofiOut: return midiCC(.lofiOut, loFi.out)
        case .enableLofi: return midiCC(.enableLofi, loFi.enable)

        // MARK: Sample

        // Pitch is not a CC to Battery. It is the note number the cell is played
        // with – see `midiNoteHandler`.
        case .pitch: return []
        }
    }
}
