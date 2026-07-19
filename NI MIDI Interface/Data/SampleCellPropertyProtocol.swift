//
//  SampleCellPropertyProtocol.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/24/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

protocol SampleCellPropertyProtocol {
    var outputValues: [String: MidiCCValueMap] { get }
}
extension SampleCellPropertyProtocol {
    
    func getUpdatedValues(
        old: SampleCellPropertyProtocol? = nil
    ) -> [MidiCCValueMap] {
        return SampleCellAmpEnvelopeData.updatedValues(
            new: self,
            old: old
        )
    }
    
    func getUpdatedMidiCCs(
        midiChannel: Int,
        old: SampleCellPropertyProtocol? = nil
    ) -> [MidiControllerChange] {
        return SampleCellAmpEnvelopeData.getUpdatedMidiCCs(
            new: self,
            old: old,
            midiChannel: midiChannel
        )
    }
    
    static func getUpdatedMidiCCs(
        new: SampleCellPropertyProtocol,
        old: SampleCellPropertyProtocol?,
        midiChannel: Int
    ) -> [MidiControllerChange] {
        let updatedValues = SampleCellAmpEnvelopeData.updatedValues(
            new: new,
            old: old
        )
        var midiCCs = [MidiControllerChange]()
        for ccEnum in updatedValues {
            if case .speed(let speed) = ccEnum {
                midiCCs.append(
                    speed.midiCCs(channel: midiChannel)
                )
                continue
            }
            guard let outCCNumber = ccEnum.midiCCInterface.midiCCOutputNumber
                else {
                    print("NO OUT NUMBER")
                    continue
            }
            let midiCC = MidiControllerChange(
                ccNumber: outCCNumber,
                value: ccEnum.midiCCValue,
                channel: midiChannel
            )
            midiCCs.append(midiCC)
        }
        return midiCCs
    }
    
    static func updatedValues(
        new: SampleCellPropertyProtocol,
        old: SampleCellPropertyProtocol?
    ) -> [MidiCCValueMap] {
        let newOutputValues = new.outputValues
        let oldOutputValues = old?.outputValues
        
        var updatedValues = [MidiCCValueMap]()
        for newValue in newOutputValues {
            guard
                let oldValue = oldOutputValues?[newValue.key],
                oldValue == newValue.value
                else {
                    updatedValues.append(newValue.value)
                    continue
            }
        }
        return updatedValues
    }
}
