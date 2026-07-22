//
//  BatteryCell.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class Cell {

    // consider adding getter and setter to protect this
    var stateData: SampleCellStateData

    private(set) var propertyData: SampleCellPropertyData
    private(set) var ampEnvelopeData: SampleCellAmpEnvelopeData
    private(set) var loFiData: SampleCellLoFiData
    private(set) var sampleData: SampleCellSampleData

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
        sampleCellData: SampleCellData
    ){
        self.propertyData = sampleCellData.propertyData
        self.stateData = sampleCellData.stateData
        self.ampEnvelopeData = sampleCellData.ampEnvelopeData
        self.loFiData = sampleCellData.loFiData
        self.sampleData = sampleCellData.sampleData
    }
}










// MARK: SET
extension Cell {
    func set(property: Property){
        switch property {
        case .lock(let value): stateData.lock = value
        }
    }
}

// MARK: UPDATE
extension Cell {

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


extension Cell {
    func unsolo(){
        self.stateData.solo = false
    }
}


extension Cell {
    
    
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
extension Cell {
    enum Property {
        case lock(value: Bool)
    }
}
