//
//  BatteryCell.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class BatteryCell {
    let channelIndex: Int

    // consider adding getter and setter to protect this
    var stateData: SampleCellStateData

    private (set) var propertyData: SampleCellPropertyData
    private (set) var ampEnvelopeData: SampleCellAmpEnvelopeData
    private (set) var loFiData: SampleCellLoFiData
    private (set) var sampleData: SampleCellSampleData

    var sampleCellData: SampleCellData {
        return SampleCellData(
            propertyData: propertyData,
            ampEnvelopeData: ampEnvelopeData,
            loFiData: loFiData,
            sampleData: sampleData,
            stateData: stateData
        )
    }
    
    //var isEditing: MidiCCValueMap?
    
    init(
        sampleCellData: SampleCellData,
        channelIndex: Int
    ){
        self.propertyData = sampleCellData.propertyData
        self.stateData = sampleCellData.stateData
        self.ampEnvelopeData = sampleCellData.ampEnvelopeData
        self.loFiData = sampleCellData.loFiData
        self.sampleData = sampleCellData.sampleData
        self.channelIndex = channelIndex
    }
}










// MARK: SET
extension BatteryCell {
    func set(property: Property){
        switch property {
        case .lock(let value): stateData.lock = value
        }
    }
}

// MARK: UPDATE
extension BatteryCell {

    /// Writes `new` into `current` if it differs.
    ///
    /// - Returns: the replaced value, or `nil` if nothing changed.
    private func write<T: Equatable>(_ new: T, _ current: inout T) -> T? {
        guard current != new else { return nil }
        let previous = current
        current = new
        return previous
    }
    
    /// A lot of diliberation was put in to how this is executed and multiple options were considered:
    ///
    /// **direct property manipulation** - The owner could route MIDI CCs to directly change the property of the cell class instance and then either: each property has a publisher (and therefore 30+ \* 16 publshers) or the owner takes a snapshot before making changes and then compares them afterwards. Side effects would need to be accounted for using `get` and `set`.
    ///
    /// This `apply` solution was chosen because it is sequential and easy to read – without needing to reason through property setters. This function simply handles side effects in one place. It leverages enums, so the compiler can enforce any missing definitions. it is slightly more efficient since it does not require snapshots and comparisons – the `diff` is generated directly as it processes the incoming changes.
    ///
    /// The downside is that it adds an artificial interface on class property changes. `snapshot and diff` also reports net results: if a single batch triggers a cascade and also explicitly sets the same parameter, it reports only the final value. `apply` must therefore dedupe the returned array by parameter identity — last write wins — to match that behavior.
    ///
    /// - Parameter intents: the changes to apply.
    /// - Returns: the previous values. Empty if nothing changed.
    func apply(_ intents: [Parameter]) -> [Parameter] {
        var previous: [Parameter] = []
        
        intents.forEach { change in
            let replaced: Parameter?
            
            switch change{
            case .start1(let v): replaced = write(v, &propertyData.start1).map(Parameter.start1)
            case .start2(let v): replaced = write(v, &propertyData.start2).map(Parameter.start2)
            case .volume(let v): replaced = write(v, &propertyData.volume).map(Parameter.volume)
            case .pan(let v): replaced = write(v, &propertyData.pan).map(Parameter.pan)
            case .speedCoarse(let v): replaced = write(v, &propertyData.speed.course).map(Parameter.speedCoarse)
            case .speedFine(let v): replaced = write(v, &propertyData.speed.fine).map(Parameter.speedFine)
            case .filterLow(let v): replaced = write(v, &propertyData.filterLow).map(Parameter.filterLow)
            case .filterHigh(let v): replaced = write(v, &propertyData.filterHigh).map(Parameter.filterHigh)
            case .transientAttack(let v): replaced = write(v, &propertyData.transientAttack).map(Parameter.transientAttack)
            case .transientSustain(let v): replaced = write(v, &propertyData.transientSustain).map(Parameter.transientSustain)
            case .enableTransientMaster(let v): replaced = write(v, &propertyData.enableTransientMaster).map(Parameter.enableTransientMaster)
            case .fineTune(let v): replaced = write(v, &propertyData.fineTune).map(Parameter.fineTune)
            case .reverbSend(let v): replaced = write(v, &propertyData.reverbSend).map(Parameter.reverbSend)
            case .delaySend(let v): replaced = write(v, &propertyData.delaySend).map(Parameter.delaySend)
            case .velocity(let v): replaced = write(v, &propertyData.velocity).map(Parameter.velocity)
            case .envOrder(let v): replaced = write(v, &propertyData.envOrder).map(Parameter.envOrder)
            case .formant(let v): replaced = write(v, &propertyData.formant).map(Parameter.formant)
            case .loopStart(let v): replaced = write(v, &propertyData.loopStart).map(Parameter.loopStart)
            case .loopStartFine(let v): replaced = write(v, &propertyData.loopStartFine).map(Parameter.loopStartFine)
            case .loopLength(let v): replaced = write(v, &propertyData.loopLength).map(Parameter.loopLength)
            case .loopLengthFine(let v): replaced = write(v, &propertyData.loopLengthFine).map(Parameter.loopLengthFine)
            case .attack(let v): replaced = write(v, &ampEnvelopeData.attack).map(Parameter.attack)
            case .hold(let v): replaced = write(v, &ampEnvelopeData.hold).map(Parameter.hold)
            case .decay(let v): replaced = write(v, &ampEnvelopeData.decay).map(Parameter.decay)
            case .sustain(let v): replaced = write(v, &ampEnvelopeData.sustain).map(Parameter.sustain)
            case .release(let v): replaced = write(v, &ampEnvelopeData.release).map(Parameter.release)
            case .enableAmpEnvelope(let v): replaced = write(v, &ampEnvelopeData.enableAmpEnv).map(Parameter.enableAmpEnvelope)
            case .lofiBits(let v): replaced = write(v, &loFiData.bits).map(Parameter.lofiBits)
            case .lofiHertz(let v): replaced = write(v, &loFiData.hertz).map(Parameter.lofiHertz)
            case .lofiNoise(let v): replaced = write(v, &loFiData.noise).map(Parameter.lofiNoise)
            case .lofiColor(let v): replaced = write(v, &loFiData.color).map(Parameter.lofiColor)
            case .lofiOut(let v): replaced = write(v, &loFiData.out).map(Parameter.lofiOut)
            case .enableLofi(let v): replaced = write(v, &loFiData.enable).map(Parameter.enableLofi)
            case .pitch(let v): replaced = write(v, &sampleData.pitch).map(Parameter.pitch)
            }
            if let replaced { previous.append(replaced) }
        }
        
        return previous
        
    }
}


extension BatteryCell {
    func unsolo(){
        self.stateData.solo = false
    }
}


// MARK: SEND TO CONTROLLER
extension BatteryCell {
    func sendToController(controllerDevice: MidiOutput) throws {
        let midiCCs = allMidiControllerCCs
        try controllerDevice.send(midiCCs: midiCCs)
    }
}



extension BatteryCell {
    
    
    var isMuted: Bool {
        return stateData.mute
    }
    var isSoloed: Bool {
        return stateData.solo
    }
    var isEditable: Bool {
        return !stateData.lock
    }
    
}

// MARK: PROPERTIES
extension BatteryCell {
    enum Property {
        case lock(value: Bool)
    }
}


extension BatteryCell {
    enum MidiInProperty {
        case attack(value: Double), hold(value: Double), decay(value: Double), sustain(value: Double), release(value: Double), enableAttackEnvelope(value: Bool)

        init(
            midiCC: MidiControllerChange
        ) throws {
            guard let inputMapping = MidiInputMapping(rawValue: midiCC.ccNumber)
                else {
                    throw NSError(domain: "no input mapping", code: 12, userInfo: nil)
            }
            switch inputMapping {
            case .attack: self = .attack(value: midiCC.ratio)
            case .hold: self = .hold(value: midiCC.ratio)
            case .decay: self = .decay(value: midiCC.ratio)
            case .sustain: self = .sustain(value: midiCC.ratio)
            case .release: self = .release(value: midiCC.ratio)
            case .enableAttackEnvelope:
                self = .enableAttackEnvelope(value: midiCC.bool)
            default: throw NSError(domain: "no matching value", code: 234, userInfo: nil)
            }
        }
    }
    
}

// MARK: GET ALL CCs
extension BatteryCell {
    /// Full state broadcast to the control surface.
    ///
    /// Iterates the controller contract itself, so every mapped control reports
    /// its current value. Controls with no readable value (actions, and `tune`,
    /// which is deliberately never broadcast) are skipped.
    ///
    /// Controller CCs always go out on channel 0.
    var allMidiControllerCCs: [MidiControllerChange] {
        return MidiInputMapping.allCases.compactMap { mapping in
            guard let value = controllerValue(for: mapping)
                else { return nil }
            return MidiControllerChange(
                ccNumber: mapping.rawValue,
                value: value,
                channel: 0
            )
        }
    }

    /// Current value of a control, in the controller's own CC vocabulary.
    /// Returns `nil` where the mapping has no readable state.
    private func controllerValue(
        for mapping: MidiInputMapping
    ) -> MidiControlChangeValue? {
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
        case .enableTransientMaster: return propertyData.enableTransientMaster.MidiCCValue
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
        case .enableAttackEnvelope: return ampEnvelopeData.enableAmpEnv.MidiCCValue

        // MARK: Lo-Fi
        case .lofiBits: return loFiData.bits.MidiCCValue
        case .lofiHertz: return loFiData.hertz.MidiCCValue
        case .lofiNoise: return loFiData.noise.MidiCCValue
        case .lofiColor: return loFiData.color.MidiCCValue
        case .lofiOut: return loFiData.out.MidiCCValue
        case .enableLofi: return loFiData.enable.MidiCCValue

        // MARK: Sample
        case .pitch: return sampleData.pitch.controllerMidiValue

        // MARK: State
        case .mute: return stateData.mute.MidiCCValue
        case .solo: return stateData.solo.MidiCCValue
        case .lock: return stateData.lock.MidiCCValue

        // MARK: No readable value

        // Coarse tune is never broadcast - only fine tune is used.
        case .tune: return nil

        // Actions have no current state to report.
        case .unsoloAll,
             .lockAll,
             .unlockAll,
             .select,
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

// MARK: HELPERS
extension BatteryCell {
    var midiNoteNumber: Int {
        return MIDINote.noteNumber(cellIndex: channelIndex)
    }
}
