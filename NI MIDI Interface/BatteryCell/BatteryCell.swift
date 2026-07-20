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
    private (set) var stateData: SampleCellStateData
    
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

    func apply(_ intents: [Change]) -> [Change] {
        var updates: [Change] = []
        
        intents.forEach { change in
            switch change{
            case .start1(let value):
                propertyData.start1 = value
            case .start2(let value):
                propertyData.start2 = value
            case .volume(let value):
                propertyData.volume = value
            case .pan(let value):
                propertyData.pan = value
            case .speedCoarse(let value):
                propertyData.speed.course = value
            case .speedFine(let value):
                propertyData.speed.fine = value
            case .filterLow(let value):
                propertyData.filterLow = value
            case .filterHigh(let value):
                propertyData.filterHigh = value
            case .transientAttack(let value):
                propertyData.transientAttack = value
            case .transientSustain(let value):
                propertyData.transientSustain = value
            case .enableTransientMaster(let value):
                propertyData.enableTransientMaster = value
            case .fineTune(let value):
                propertyData.fineTune = value
            case .reverbSend(let value):
                propertyData.reverbSend = value
            case .delaySend(let value):
                propertyData.delaySend = value
            case .velocity(let value):
                propertyData.velocity = value
            case .envOrder(let value):
                propertyData.envOrder = value
            case .formant(let value):
                propertyData.formant = value
            case .loopStart(let value):
                propertyData.loopStart = value
            case .loopStartFine(let value):
                propertyData.loopStartFine = value
            case .loopLength(let value):
                propertyData.loopLength = value
            case .loopLengthFine(let value):
                propertyData.loopLengthFine = value
            case .attack(let value):
                ampEnvelopeData.attack = value
            case .hold(let value):
                ampEnvelopeData.hold = value
            case .decay(let value):
                ampEnvelopeData.decay = value
            case .sustain(let value):
                ampEnvelopeData.sustain = value
            case .release(let value):
                ampEnvelopeData.release = value
            case .enableAmpEnvelope(let value):
                ampEnvelopeData.enableAmpEnv = value
            case .lofiBits(let value):
                loFiData.bits = value
            case .lofiHertz(let value):
                loFiData.hertz = value
            case .lofiNoise(let value):
                loFiData.noise = value
            case .lofiColor(let value):
                loFiData.color = value
            case .lofiOut(let value):
                loFiData.out = value
            case .enableLofi(let value):
                loFiData.enable = value
            case .pitch(let value):
                sampleData.pitch = value
            case .mute(let value):
                stateData.mute = value
            case .solo(let value):
                stateData.solo = value
            case .lock(let value):
                stateData.lock = value
            }
            updates.append(change)
        }
        
        return updates
        
    }
    
    /// A lot of diliberation was put in to how this is executed and multiple options were considered:
    ///
    /// **direct property manipulation** - The owner could route MIDI CCs to directly change the property of the cell class instance and then either: each property has a publisher (and therefore 30+ \* 16 publshers) or the owner takes a snapshot before making changes and then compares them afterwards. Side effects would need to be accounted for using `get` and `set`.
    ///
    /// This `apply` solution was chosen because it is sequential and easy to read – without needing to reason through property setters. This function simply handles side effects in one place. It leverages enums, so the compiler can enforce any missing definitions. it is slightly more efficient since it does not require snapshots and comparisons – the `diff` is generated directly as it processes the incoming changes.
    ///
    /// The downside is that it adds an artificial interface on class property changes. `snapshot and diff` also reports net results: if a single batch triggers a cascade and also explicitly sets the same parameter, it reports only the final value. `apply` must therefore dedupe the returned array by parameter identity — last write wins — to match that behavior.
    ///
    /// - Parameters:
    ///   - midiCC: <#midiCC description#>
    ///   - destination: <#destination description#>
    func update(
        midiCC: MidiControllerChange,
        destination: MidiCCInterface.Destination
    ){

        guard let inputMapping = MidiInputMapping(rawValue: midiCC.ccNumber)
            else {
                print("NO MATCHING MAPPING")
                return
        }
        switch destination {
        case .ampEnvelope:
            self.updateAmpEnv(midiCC: midiCC, inputMapping: inputMapping)
        case .loFi:
            self.updateLoFi(midiCC: midiCC, inputMapping: inputMapping)
        case .sampleData:
            updateSampleData(midiCC: midiCC, inputMapping: inputMapping)
        case .sampleCellProperty:
            updateSampleProperty(midiCC: midiCC, inputMapping: inputMapping)
        default: print("WRONG SPOT!!")
        }
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
    var allMidiControllerCCs: [MidiControllerChange] {
        var ccEnums = allMidiVals
        ccEnums.append(contentsOf: stateData.getAllMidiCCs(
            channel: 0)
        )
        var midiCCs = [MidiControllerChange]()
        for ccEnum in ccEnums {
            if case .speed(let speed) = ccEnum {
                let midiCC = MidiControllerChange(
                    ccNumber: MidiInputMapping.fineSpeed.rawValue,
                    value: speed.fine.MidiCCValue,
                    channel: 0
                )
                midiCCs.append(midiCC)
            }
            let midiCC = MidiControllerChange(ccNumber: ccEnum.midiCCInterface.controllerMidiCCNumber, value: ccEnum.midiCCValue, channel: 0
            )
            midiCCs.append(midiCC)
        }
        return midiCCs
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
