//
//  SampleCellDataMIDICCExtension.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

extension SampleCellPropertyData {
    func getAllMidiCCs(channel: MidiChannel) -> [MidiCCValueMap] {
        return [
            .start1(value: start1), .start2(value: start2),
            .volume(value: volume), .pan(value: pan),
            .speed(value: speed), .fineSpeed(value: fineSpeed),
            .pitch(pitch: pitch),
            .filterLow(value: filterLow), .filterHigh(value: filterHigh),
            .attack(value: attack), .hold(value: hold), .decay(value: decay), .sustain(value: sustain), .release(value: release), .enableAttackEnvelope(value: enableAttackEnvelope),
            .transientAttack(value: transientAttack), .transientSustain(value: transientSustain), .enableTransientMaster(value: enableTransientMaster),
            .tune(value: tune), .fineTune(value: fineTune),
            .lofiBits(value: lofiBits), .lofiHertz(value: lofiHertz), .lofiNoise(value: lofiNoise), .lofiColor(value: lofiColor), .lofiOut(value: lofiOut), .enableLofi(value: enableLofi),
            .reverbSend(value: reverbSend), .delaySend(value: delaySend),
            .velocity(value: velocity),
            .envOrder(value: envOrder), .formant(value: formant)
        ]
    }
}
