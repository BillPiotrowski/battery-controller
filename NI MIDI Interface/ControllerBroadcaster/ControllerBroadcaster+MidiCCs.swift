//
//  ControllerBroadcaster+MidiCCs.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

// MARK: ENCODE
extension ControllerBroadcaster {

    static func midiCCs(for data: SampleCellData) -> [MidiControllerChange] {
        return MidiInputMapping.allCases.compactMap { mapping in
            guard let value = ControllerBroadcaster.value(for: mapping, data: data)
                else { return nil }
            return MidiControllerChange(
                ccNumber: mapping.rawValue,
                value: value,
                channel: channel
            )
        }
    }

    /// Current values for a set of parameters, in the controller's CC vocabulary.
    ///
    /// payloads are ignored - the value is always read
    /// from `data`. Used to re-assert a cell's truth after a rejected edit.
    static func midiCCs(
        for parameters: [Cell.Parameter],
        data: SampleCellData
    ) -> [MidiControllerChange] {
        var midiCCs = [MidiControllerChange]()
        var claimedCCNumbers = Set<MidiControlChangeNumber>()

        for parameter in parameters {
            let mapping = ControllerBroadcaster.mapping(for: parameter)
            guard let value = ControllerBroadcaster.value(for: mapping, data: data)
                else { continue }
            guard claimedCCNumbers.insert(mapping.rawValue).inserted
                else { continue }
            midiCCs.append(
                MidiControllerChange(
                    ccNumber: mapping.rawValue,
                    value: value,
                    channel: channel
                )
            )
        }
        return midiCCs
    }

    private static func mapping(for parameter: Cell.Parameter) -> MidiInputMapping {
        switch parameter {
        case .start1: return .start1
        case .start2: return .start2
        case .volume: return .volume
        case .pan: return .pan
        case .speedCoarse: return .speed
        case .speedFine: return .fineSpeed
        case .filterLow: return .filterLow
        case .filterHigh: return .filterHigh
        case .transientAttack: return .transientAttack
        case .transientSustain: return .transientSustain
        case .enableTransientMaster: return .toggleTransientMaster
        case .fineTune: return .fineTune
        case .reverbSend: return .reverbSend
        case .delaySend: return .delaySend
        case .velocity: return .velocity
        case .envOrder: return .envOrder
        case .formant: return .formant
        case .loopStart: return .loopStart
        case .loopStartFine: return .loopStartFine
        case .loopLength: return .loopLength
        case .loopLengthFine: return .loopLengthFine
        case .attack: return .attack
        case .hold: return .hold
        case .decay: return .decay
        case .sustain: return .sustain
        case .release: return .release
        case .enableAmpEnvelope: return .toggleAmpEnvelope
        case .lofiBits: return .lofiBits
        case .lofiHertz: return .lofiHertz
        case .lofiNoise: return .lofiNoise
        case .lofiColor: return .lofiColor
        case .lofiOut: return .lofiOut
        case .enableLofi: return .toggleLofi
        case .pitch: return .pitch
        }
    }

    private static func value(
        for mapping: MidiInputMapping,
        data: SampleCellData
    ) -> MidiControlChangeValue? {
        let propertyData = data.propertyData
        let ampEnvelopeData = data.ampEnvelopeData
        let loFiData = data.loFiData
        let sampleData = data.sampleData
        let stateData = data.stateData

        switch mapping {

        // MARK: Property
        case .start1: return propertyData.start1.MidiCCValue
        case .start2: return propertyData.start2.MidiCCValue
        case .volume: return propertyData.volume.MidiCCValue
        case .pan: return propertyData.pan.MidiCCValue
        case .speed: return propertyData.speed.course.MidiCCValue
        case .fineSpeed: return propertyData.speed.fine.MidiCCValue
        case .filterLow: return propertyData.filterLow.MidiCCValue
        case .filterHigh: return propertyData.filterHigh.MidiCCValue
        case .transientAttack: return propertyData.transientAttack.MidiCCValue
        case .transientSustain: return propertyData.transientSustain.MidiCCValue
        case .toggleTransientMaster: return propertyData.enableTransientMaster.MidiCCValue
        case .fineTune: return propertyData.fineTune.MidiCCValue
        case .reverbSend: return propertyData.reverbSend.MidiCCValue
        case .delaySend: return propertyData.delaySend.MidiCCValue
        case .velocity: return propertyData.velocity.MidiCCValue
        case .envOrder: return propertyData.envOrder.MidiCCValue
        case .formant: return propertyData.formant.MidiCCValue
        case .loopStart: return propertyData.loopStart.MidiCCValue
        case .loopStartFine: return propertyData.loopStartFine.MidiCCValue
        case .loopLength: return propertyData.loopLength.MidiCCValue
        case .loopLengthFine: return propertyData.loopLengthFine.MidiCCValue

        // MARK: Amp Envelope
        case .attack: return ampEnvelopeData.attack.MidiCCValue
        case .hold: return ampEnvelopeData.hold.MidiCCValue
        case .decay: return ampEnvelopeData.decay.MidiCCValue
        case .sustain: return ampEnvelopeData.sustain.MidiCCValue
        case .release: return ampEnvelopeData.release.MidiCCValue
        case .toggleAmpEnvelope: return ampEnvelopeData.enableAmpEnv.MidiCCValue

        // MARK: Lo-Fi
        case .lofiBits: return loFiData.bits.MidiCCValue
        case .lofiHertz: return loFiData.hertz.MidiCCValue
        case .lofiNoise: return loFiData.noise.MidiCCValue
        case .lofiColor: return loFiData.color.MidiCCValue
        case .lofiOut: return loFiData.out.MidiCCValue
        case .toggleLofi: return loFiData.enable.MidiCCValue

        // MARK: Sample
        case .pitch: return sampleData.pitch.controllerMidiValue

        // MARK: State
        case .toggleMute: return stateData.mute.MidiCCValue
        case .toggleSolo: return stateData.solo.MidiCCValue
        case .toggleLock: return stateData.lock.MidiCCValue

        // MARK: No readable value

        // Coarse tune is never broadcast - only fine tune is used.
        case .tune: return nil

        // Actions have no current state to report.
        case .unsoloAll,
             .lockAll,
             .unlockAll,
             .toggleSelect,
             .copy,
             .paste,
             .reset,
             .resetAll,
             .undo,
             .redo:
            return nil
        }
    }
}
