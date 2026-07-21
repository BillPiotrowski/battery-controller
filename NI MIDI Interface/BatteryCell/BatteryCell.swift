//
//  BatteryCell.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

class BatteryCell {
    private let midi: MIDI
    let channelIndex: Int
    //private (set) var sampleCellData: SampleCellData
    
    // consider adding getter and setter to protect this
    var stateData: SampleCellStateData
    
    private (set) var propertyData: SampleCellPropertyData
    private (set) var ampEnvelopeData: SampleCellAmpEnvelopeData
    private (set) var loFiData: SampleCellLoFiData
    private (set) var sampleData: SampleCellSampleData
    
    private weak var samplerOutputSelection: MidiOutput?
    private weak var undoManager: UndoManager?
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
        midi: MIDI,
        channelIndex: Int,
        samplerOutputSelection: MidiOutput,
        undoManager: UndoManager
    ){
        self.propertyData = sampleCellData.propertyData
        self.stateData = sampleCellData.stateData
        self.ampEnvelopeData = sampleCellData.ampEnvelopeData
        self.loFiData = sampleCellData.loFiData
        self.sampleData = sampleCellData.sampleData
        //self.sampleCellData = sampleCellData
        self.midi = midi
        self.channelIndex = channelIndex
        self.samplerOutputSelection = samplerOutputSelection
        self.undoManager = undoManager
    }
}










// MARK: SET
extension BatteryCell {
    func set(property: Property){
        switch property {
        case .lock(let value): stateData.lock = value
        }
    }
    func set(
        propertyProtocol: SampleCellPropertyProtocol
    ) -> SampleCellPropertyProtocol? {
        let previous: SampleCellPropertyProtocol
        if let ampEnvData = propertyProtocol as? SampleCellAmpEnvelopeData {
            previous = self.ampEnvelopeData
            self.ampEnvelopeData = ampEnvData
        } else if let loFiData = propertyProtocol as? SampleCellLoFiData {
            previous = self.loFiData
            self.loFiData = loFiData
        } else if let propertyData = propertyProtocol as? SampleCellPropertyData {
            previous = self.propertyData
            self.propertyData = propertyData
        } else if let sampleData = propertyProtocol as? SampleCellSampleData {
            previous = self.sampleData
            self.sampleData = sampleData
        } else {
            print("NO PREVIOUS")
            return nil
        }
        registerData(previous: previous)
        let midiCCs = propertyProtocol.getUpdatedMidiCCs(midiChannel: self.channelIndex, old: previous)
        sendToSampler(midiCCs: midiCCs)
        return previous
    }
}

// MARK: SEND TO SAMPLER
extension BatteryCell {
    private func sendToSampler(midiCCs: [MidiControllerChange]){
        do {
            try samplerOutputSelection?.send(midiCCs: midiCCs)
        } catch {
            print(error)
        }
    }
}

// MARK: RESET
extension BatteryCell {
    func reset(){
        _ = self.set(propertyProtocol: SampleCellPropertyData.default)
        _ = self.set(propertyProtocol: SampleCellAmpEnvelopeData.default)
        _ = self.set(propertyProtocol: SampleCellLoFiData.default)
        _ = self.set(propertyProtocol: SampleCellSampleData.default)
        //self.propertyData = SampleCellPropertyData.default
        //self.ampEnvelopeData = SampleCellAmpEnvelopeData.default
        //self.loFiData = SampleCellLoFiData.default
        //self.sampleData = SampleCellSampleData.default
        
        print("Channel: \(channelIndex)")
        //let midiCCs = self.allMIDISamplerCCs
        //print(midiCCs)
        //sendToSampler(midiCCs: midiCCs)
        //let midiCCs2 = propertyData.getUpdatedMidiCCs(midiChannel: channelIndex)
        //sendToSampler(midiCCs: midiCCs2)
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
    /// The downside is that it adds an artificial interface on class property changes.

    /// - Parameter intents: the changes to apply.
    /// - Returns: the previous values. Empty if nothing changed.
    func apply(_ intents: [Change]) -> [Change] {
        var previous: [Change] = []
        
        intents.forEach { change in
            let replaced: Change?
            
            switch change{
            case .start1(let v): replaced = write(v, &propertyData.start1).map(Change.start1)
            case .start2(let v): replaced = write(v, &propertyData.start2).map(Change.start2)
            case .volume(let v): replaced = write(v, &propertyData.volume).map(Change.volume)
            case .pan(let v): replaced = write(v, &propertyData.pan).map(Change.pan)
            case .speedCoarse(let v): replaced = write(v, &propertyData.speed.course).map(Change.speedCoarse)
            case .speedFine(let v): replaced = write(v, &propertyData.speed.fine).map(Change.speedFine)
            case .filterLow(let v): replaced = write(v, &propertyData.filterLow).map(Change.filterLow)
            case .filterHigh(let v): replaced = write(v, &propertyData.filterHigh).map(Change.filterHigh)
            case .transientAttack(let v): replaced = write(v, &propertyData.transientAttack).map(Change.transientAttack)
            case .transientSustain(let v): replaced = write(v, &propertyData.transientSustain).map(Change.transientSustain)
            case .enableTransientMaster(let v): replaced = write(v, &propertyData.enableTransientMaster).map(Change.enableTransientMaster)
            case .fineTune(let v): replaced = write(v, &propertyData.fineTune).map(Change.fineTune)
            case .reverbSend(let v): replaced = write(v, &propertyData.reverbSend).map(Change.reverbSend)
            case .delaySend(let v): replaced = write(v, &propertyData.delaySend).map(Change.delaySend)
            case .velocity(let v): replaced = write(v, &propertyData.velocity).map(Change.velocity)
            case .envOrder(let v): replaced = write(v, &propertyData.envOrder).map(Change.envOrder)
            case .formant(let v): replaced = write(v, &propertyData.formant).map(Change.formant)
            case .loopStart(let v): replaced = write(v, &propertyData.loopStart).map(Change.loopStart)
            case .loopStartFine(let v): replaced = write(v, &propertyData.loopStartFine).map(Change.loopStartFine)
            case .loopLength(let v): replaced = write(v, &propertyData.loopLength).map(Change.loopLength)
            case .loopLengthFine(let v): replaced = write(v, &propertyData.loopLengthFine).map(Change.loopLengthFine)
            case .attack(let v): replaced = write(v, &ampEnvelopeData.attack).map(Change.attack)
            case .hold(let v): replaced = write(v, &ampEnvelopeData.hold).map(Change.hold)
            case .decay(let v): replaced = write(v, &ampEnvelopeData.decay).map(Change.decay)
            case .sustain(let v): replaced = write(v, &ampEnvelopeData.sustain).map(Change.sustain)
            case .release(let v): replaced = write(v, &ampEnvelopeData.release).map(Change.release)
            case .enableAmpEnvelope(let v): replaced = write(v, &ampEnvelopeData.enableAmpEnv).map(Change.enableAmpEnvelope)
            case .lofiBits(let v): replaced = write(v, &loFiData.bits).map(Change.lofiBits)
            case .lofiHertz(let v): replaced = write(v, &loFiData.hertz).map(Change.lofiHertz)
            case .lofiNoise(let v): replaced = write(v, &loFiData.noise).map(Change.lofiNoise)
            case .lofiColor(let v): replaced = write(v, &loFiData.color).map(Change.lofiColor)
            case .lofiOut(let v): replaced = write(v, &loFiData.out).map(Change.lofiOut)
            case .enableLofi(let v): replaced = write(v, &loFiData.enable).map(Change.enableLofi)
            case .pitch(let v): replaced = write(v, &sampleData.pitch).map(Change.pitch)
            }
            if let replaced { previous.append(replaced) }
        }
        
        return previous
        
    }
}


// MARK: UPDATE SAMPLE PROPS
extension BatteryCell {
    private func updateSampleProperty(
        midiCC: MidiControllerChange,
        inputMapping: MidiInputMapping
    ){
        print(midiCC)
        var newPropertyData = propertyData
        switch inputMapping {
        case .start1: newPropertyData.start1 = midiCC.ratio
        case .start2: newPropertyData.start2 = midiCC.ratio
        case .volume: newPropertyData.volume = midiCC.ratio
        case .filterLow: newPropertyData.filterLow = midiCC.ratio
        case .filterHigh: newPropertyData.filterHigh = midiCC.ratio
        case .transientAttack:
            newPropertyData.transientAttack = midiCC.ratio
        case .transientSustain:
            newPropertyData.transientSustain = midiCC.ratio
        case .enableTransientMaster:
            newPropertyData.enableTransientMaster = midiCC.bool
        case .tune:
            // ONLY ALLOW FINE TUNE!!
            break
            //newPropertyData.tune = midiCC.ratio
        case .fineTune: newPropertyData.fineTune = midiCC.ratio
        case .reverbSend: newPropertyData.reverbSend = midiCC.ratio
        case .delaySend: newPropertyData.delaySend = midiCC.ratio
        case .velocity: newPropertyData.velocity = midiCC.ratio
        case .envOrder: newPropertyData.envOrder = midiCC.ratio
        case .formant: newPropertyData.formant = midiCC.ratio
        case .pan: newPropertyData.pan = midiCC.ratio
        case .speed:
            var speed = newPropertyData.speed
            speed.course = midiCC.ratio
            newPropertyData.speed = speed
        case .fineSpeed:
            var speed = newPropertyData.speed
            speed.fine = midiCC.ratio
            newPropertyData.speed = speed
            //newPropertyData.fineSpeed = midiCC.ratio
        case .reset:
            print("RESET 2")
            self.reset()
            // NO NEED TO SET, SO RETURN
            // WILL OVERRIDE RESET IF IF CONTINUES TO set() func below.
            return
        case .loopStart: newPropertyData.loopStart = midiCC.ratio
        case .loopStartFine:
            newPropertyData.loopStartFine = midiCC.ratio
        case .loopLength:
            newPropertyData.loopLength = midiCC.ratio
        case .loopLengthFine:
            newPropertyData.loopLengthFine = midiCC.ratio
        default:
            print("BAD COMMAND TO PROPERTY DATA")
            break
        }
        print(newPropertyData)
        _ = self.set(propertyProtocol: newPropertyData)
    }
}

// MARK: UPDATE SAMPLE DATA
extension BatteryCell {
    private func updateSampleData(
        midiCC: MidiControllerChange,
        inputMapping: MidiInputMapping
    ){
        var newSampleData = sampleData
        switch inputMapping {
        case .pitch: newSampleData.pitch = Pitch(value: midiCC.ratio)
        default: break
        }
        _ = set(propertyProtocol: newSampleData)
    }
}


// MARK: UPDATE AMP ENV
extension BatteryCell {
    private func updateAmpEnv(
        midiCC: MidiControllerChange,
        inputMapping: MidiInputMapping
    ){
        var newAmpEnvelopeData = ampEnvelopeData
        switch inputMapping {
        case .attack: newAmpEnvelopeData.attack = midiCC.ratio
        case .hold: newAmpEnvelopeData.hold = midiCC.ratio
        case .decay: newAmpEnvelopeData.decay = midiCC.ratio
        case .sustain: newAmpEnvelopeData.sustain = midiCC.ratio
        case .release: newAmpEnvelopeData.release = midiCC.ratio
        case .enableAttackEnvelope:
            newAmpEnvelopeData.enableAmpEnv = midiCC.bool
        default: break
        }
        _ = self.set(propertyProtocol: newAmpEnvelopeData)
    }
}
// MARK: UPDATE LOFI
extension BatteryCell {
    private func updateLoFi(
        midiCC: MidiControllerChange,
        inputMapping: MidiInputMapping
    ){
        var newLoFiData = loFiData
        switch inputMapping {
        case .lofiBits: newLoFiData.bits = midiCC.ratio
        case .lofiHertz: newLoFiData.hertz = midiCC.ratio
        case .lofiNoise: newLoFiData.noise = midiCC.ratio
        case .lofiColor: newLoFiData.color = midiCC.ratio
        case .lofiOut: newLoFiData.out = midiCC.ratio
        case .enableLofi: newLoFiData.enable = midiCC.bool
        default: break
        }
        _ = self.set(propertyProtocol: newLoFiData)
    }
}

// MARK: UPDATE STATE
// NOT UNDOABLE
extension BatteryCell {
    func setStateFrom(midiCC: MidiCCValueMap){
        guard case .sampleCellState = midiCC.midiCCInterface.destination
            else {
                print("WARNING: MIDI CC is not state.")
                return
        }
        switch midiCC {
        case .mute(let value): self.stateData.mute = value
        case .solo(let value): self.stateData.solo = value
        case .isEditingLocked(let value): self.stateData.lock = value
        default:
            print("WARNING: MidiCC state not handled.")
        }
    }
}

extension BatteryCell {
    func unsolo(){
        self.stateData.solo = false
    }
}


// MARK: REGISTER UNDO
extension BatteryCell {
    private func registerData(
        previous: SampleCellPropertyProtocol
    ){
        undoManager?.registerUndo(withTarget: self){
            //$0.isEditing = nil
            guard let temp = $0.set(propertyProtocol: previous)
                else { return }
            $0.registerData(previous: temp)
        }
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
    var allMidiVals: [MidiCCValueMap] {
        var allMidiVals = [MidiCCValueMap]()
        allMidiVals.append(
            contentsOf: propertyData.getUpdatedValues()
        )
        allMidiVals.append(
            contentsOf: loFiData.getUpdatedValues()
        )
        allMidiVals.append(
            contentsOf: ampEnvelopeData.getUpdatedValues()
        )
        allMidiVals.append(
            contentsOf: sampleData.getUpdatedValues()
        )
        return allMidiVals
    }
    var allMIDISamplerCCs: [MidiControllerChange] {
        let allMidiVals = self.allMidiVals
        var midiCCs = [MidiControllerChange]()
        for ccEnum in allMidiVals {
            guard let ccNumber = ccEnum.midiCCInterface.midiCCOutputNumber
                else { continue }
            let midiCC = MidiControllerChange(
                ccNumber: ccNumber,
                value: ccEnum.midiCCValue,
                channel: self.channelIndex
            )
            midiCCs.append(midiCC)
        }
        return midiCCs
    }
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

// MARK: COPY & PASTE
extension BatteryCell {
    func copy() -> [SampleCellPropertyProtocol] {
        return [
            propertyData,
            sampleData,
            ampEnvelopeData,
            loFiData
        ]
    }
    func paste(datas: [SampleCellPropertyProtocol]){
        for data in datas {
            _ = set(propertyProtocol: data)
        }
    }
}

// MARK: HELPERS
extension BatteryCell {
    var midiNoteNumber: Int {
        return MIDINote.noteNumber(cellIndex: channelIndex)
    }
}
