//
//  MaschineInterface.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation
import ReactiveSwift




class MaschineInterface {
    private var editingCellIndex: Int
    
    var samplerOutputSelection: MidiOutput
    
    var controllerOutputDevice: MidiOutput
    var controllerInput: MidiInput
    var keyboardInput: MidiInput
    private var undoGroup: UndoGroup?
    
    private let undoManager: UndoManager
    
    private var isSelectionLocked: Bool
    
    private var copiedPropertyData: [SampleCellPropertyProtocol]?
    
    /* private */ let midi: MIDI
    private let batteryCells: [BatteryCell]
    var noteObserver: Disposable?
    var keyboardNoteObserver: Disposable?
    var ccObserver: Disposable?
    var documentData: DocumentData {
        var sampleCellsData = [SampleCellData]()
        for sampleCell in batteryCells {
            sampleCellsData.append(sampleCell.sampleCellData)
        }
        return DocumentData(sampleCellsData: sampleCellsData)
    }
    
    init(documentData: DocumentData, midi: MIDI) throws {
        guard documentData.sampleCellsData.count == 16
            else { throw NSError(domain: "not 16 cells", code: 23, userInfo: nil)}
        let samplerOutputSelection = MidiOutput(
            midi: midi,
            selectedDeviceIndex: nil
        )
        let undoManager = UndoManager()
        var batteryCells = [BatteryCell]()
        for n in 0...15 {
            let batteryCell = BatteryCell(
                sampleCellData: documentData.sampleCellsData[n],
                midi: midi,
                channelIndex: n,
                samplerOutputSelection: samplerOutputSelection,
                undoManager: undoManager
            )
            batteryCells.append(batteryCell)
        }
        
        self.samplerOutputSelection = samplerOutputSelection
        self.controllerOutputDevice = MidiOutput(midi: midi, selectedDeviceIndex: nil)
        self.controllerInput = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.keyboardInput = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.editingCellIndex = 0
        self.midi = midi
        self.batteryCells = batteryCells
        self.isSelectionLocked = false
        self.undoManager = undoManager
        
        self.undoManager.groupsByEvent = false
        
        
        self.noteObserver = controllerInput.midiNoteObserver.observe(Signal<MIDINote, Never>.Observer(
            value: self.midiNoteHandler(midiNote:),
            failed: {error in},
            completed: {},
            interrupted: {}))
        
        self.keyboardNoteObserver = keyboardInput.midiNoteObserver.observe(Signal<MIDINote, Never>.Observer(
            value: self.midiKeyboardNoteHandler(midiNote:)))
        
        self.ccObserver = controllerInput.midiCCObserver.observe(Signal<MidiControllerChange, Never>.Observer(value: self.midiCCHandler(midiCC:)))
        
        samplerOutputSelection.midiDeviceSelection.signal.observe(Signal<[MidiOutputInfo], Never>.Observer(value: {value in
            self.sendAll()
        }))
        sendAll()
        updateController()
    }
    
    deinit{
        self.dispose()
    }
}

// MARK: DISPOSE
extension MaschineInterface {
    func dispose(){
        print("DISPOSING!!")
        noteObserver?.dispose()
        ccObserver?.dispose()
        keyboardNoteObserver?.dispose()
    }
}

// MARK: SEND CC TO:
extension MaschineInterface {
    private func sendAll(){
        sendToSampler(midiCCs: self.allToSamplerCCs)
    }
    
    private func sendToSampler(midiCCs: [MidiControllerChange]){
        do {
            try samplerOutputSelection.send(midiCCs: midiCCs)
        } catch {
            print("ERROR SENDING TO SAMPLER: \(error).")
        }
    }
    private func sendToController(midiCCs: [MidiControllerChange]){
        let selectedMidiNote = MIDINote(
            noteNumber: selectedCell.midiNoteNumber,
            velocity: 127,
            isNoteOn: true
        )
        do {
            for batteryCell in batteryCells {
                let deselectedMidiNote = MIDINote(
                    noteNumber: batteryCell.midiNoteNumber,
                    velocity: 0,
                    isNoteOn: false
                )
                try controllerOutputDevice.send(
                    midiNote: deselectedMidiNote,
                    channel: 0
                )
            }
            try controllerOutputDevice.send(midiCCs: midiCCs)
            try controllerOutputDevice.send(
                midiNote: selectedMidiNote,
                channel: 0
            )
        } catch {
            print("ERROR SENDING TO SAMPLER: \(error).")
        }
    }
    
    private var allToSamplerCCs: [MidiControllerChange] {
        var midiCCs = [MidiControllerChange]()
        for sampleCell in batteryCells {
            midiCCs.append(contentsOf: sampleCell.allMIDISamplerCCs)
        }
        return midiCCs
    }
    private var allToControllerCCs: [MidiControllerChange] {
        let selectedSampleCell = batteryCells[editingCellIndex]
        var midiCCs = [MidiControllerChange]()
        midiCCs.append(
            contentsOf: selectedSampleCell.allMidiControllerCCs
        )
        return midiCCs
    }
    
    private func updateController(){
        sendToController(midiCCs: allToControllerCCs)
    }
}

// MARK: CELL INDEX
extension MaschineInterface {
    private func setEditingCellIndex(cellIndex: Int){
        guard !isSelectionLocked
            else {
                //print("WARNING: Can not check selection because it is locked.")
                return
        }
        guard editingCellIndex != cellIndex
            else {
                //print("SAME INDEX")
                return
        }
        self.editingCellIndex = cellIndex
        updateController()
    }
}

// MARK: MIDI NOTE CHANGE
extension MaschineInterface {
    private func midiKeyboardNoteHandler(midiNote: MIDINote){
        do {
            try samplerOutputSelection.send(
                midiNote: midiNote,
                channel: editingCellIndex
            )
        } catch {
            print(error)
        }
        
    }
    private func midiNoteHandler(midiNote: MIDINote){
        let isNoteOn = midiNote.velocity > 0 && midiNote.isNoteOn
        guard let cellIndex = midiNote.cellIndex
            else {
                print("No cell index.")
                return
        }
        if isNoteOn {
            setEditingCellIndex(cellIndex: cellIndex)
        }
        guard isPlayable(batteryCell: batteryCells[cellIndex])
            else {
                print("CAN NOT PLAY")
                return
        }
        let pitch = batteryCells[cellIndex].sampleCellData.sampleData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: isNoteOn
        )
        do {
            try samplerOutputSelection.send(
                midiNote: newMidiNote,
                channel: cellIndex
            )
        } catch {
            print(error)
        }
        
    }
    // MORE EFFICIENT WAY OF DOING THIS??
    private var isAnySoloed: Bool {
        for cell in batteryCells {
            if cell.isSoloed {
                return true
            }
        }
        return false
    }
    private func isPlayable(batteryCell: BatteryCell) -> Bool {
        if batteryCell.isMuted { return false }
        if isAnySoloed { return batteryCell.isSoloed }
        return true
    }
}
// MARK: MIDI CC CHANGE
extension MaschineInterface {

  enum RouterError: ScorepioError {
      case unmappedCC(MidiControlChangeNumber)
  
      var message: String {
          switch self {
          case .unmappedCC(let n): return "No input mapping for CC \(n)."
          }
      }
  }

    private func midiCCHandler(midiCC: MidiControllerChange){
        do {
            guard let sampleProperty = MidiInputMapping(rawValue: midiCC.ccNumber) else {
                throw RouterError.unmappedCC(midiCC.ccNumber)
            }
            
            // MASTER
            switch sampleProperty {
            case .unsoloAll:
                guard midiCC.bool else { return }
                self.unsoloAll()
                return
            case .unlockAll:
                guard midiCC.bool else { return }
                self.unlockAll()
                return
            case .lockAll:
                guard midiCC.bool else { return }
                self.lockAll()
                return
//            case .isSelectionLocked(let value): self.isSelectionLocked = value
            case .copy:
                guard midiCC.bool else { return }
                self.copy()
                return
            case .paste:
                guard midiCC.bool else { return }
                self.paste()
                return
            case .undo:
                guard midiCC.bool else { return }
                self.undo()
                return
            case .redo:
                guard midiCC.bool else { return }
                self.redo()
                return
            case .resetAll:
                guard midiCC.bool else { return }
                self.resetAll()
                return

            case .select:
                self.isSelectionLocked = midiCC.bool
                return
                
            default: break
            }
            
            // does this require a guard?
            let batteryCell = batteryCells[editingCellIndex]
            
            
            switch sampleProperty {
            case .mute:
                batteryCell.stateData.mute = midiCC.bool
                return
            case .solo:
                batteryCell.stateData.solo = midiCC.bool
                return
            case .lock:
                batteryCell.stateData.lock = midiCC.bool
                return
            case .reset:
                batteryCell.reset()
                return
            
            default: break
            }
            
            
            
//            let sampleProperty = try MidiCCInterface(inputNumber: midiCC.ccNumber)
            


            
            guard let change = MaschineInterface.getChange(mapping: sampleProperty, midiCC: midiCC) else {
//                throw RouterError.unmappedCC(midiCC.ccNumber)
                return
            }
            
            let previous = batteryCell.apply([change])
            guard !previous.isEmpty else { return }
            set(newUndoGroup: UndoGroup(task: sampleProperty, sampleCellIndex: editingCellIndex))
            registerUndo(previous: previous, cellIndex: editingCellIndex)
            // `previous` carries the old values, but only its case identity is
            // used - the cell is the value authority.
            broadcastToSampler(previous, cell: batteryCell)

        }
        catch { print(error) }
    }
    
    static func getChange(mapping: MidiInputMapping, midiCC: MidiControllerChange) -> BatteryCell.Parameter? {
        switch mapping {

        // MARK: Property
        case .start1: return .start1(midiCC.ratio)
        case .start2: return .start2(midiCC.ratio)
        case .volume: return .volume(midiCC.ratio)
        case .pan: return .pan(midiCC.ratio)
        case .speed: return .speedCoarse(midiCC.ratio)
        case .fineSpeed: return .speedFine(midiCC.ratio)
        case .filterLow: return .filterLow(midiCC.ratio)
        case .filterHigh: return .filterHigh(midiCC.ratio)
        case .transientAttack: return .transientAttack(midiCC.ratio)
        case .transientSustain: return .transientSustain(midiCC.ratio)
        case .enableTransientMaster: return .enableTransientMaster(midiCC.bool)
        case .fineTune: return .fineTune(midiCC.ratio)
        case .reverbSend: return .reverbSend(midiCC.ratio)
        case .delaySend: return .delaySend(midiCC.ratio)
        case .velocity: return .velocity(midiCC.ratio)
        case .envOrder: return .envOrder(midiCC.ratio)
        case .formant: return .formant(midiCC.ratio)
        case .loopStart: return .loopStart(midiCC.ratio)
        case .loopStartFine: return .loopStartFine(midiCC.ratio)
        case .loopLength: return .loopLength(midiCC.ratio)
        case .loopLengthFine: return .loopLengthFine(midiCC.ratio)

        // MARK: Amp Envelope
        case .attack: return .attack(midiCC.ratio)
        case .hold: return .hold(midiCC.ratio)
        case .decay: return .decay(midiCC.ratio)
        case .sustain: return .sustain(midiCC.ratio)
        case .release: return .release(midiCC.ratio)
        case .enableAttackEnvelope: return .enableAmpEnvelope(midiCC.bool)

        // MARK: Lo-Fi
        case .lofiBits: return .lofiBits(midiCC.ratio)
        case .lofiHertz: return .lofiHertz(midiCC.ratio)
        case .lofiNoise: return .lofiNoise(midiCC.ratio)
        case .lofiColor: return .lofiColor(midiCC.ratio)
        case .lofiOut: return .lofiOut(midiCC.ratio)
        case .enableLofi: return .enableLofi(midiCC.bool)

        // MARK: Sample
        case .pitch: return .pitch(Pitch(value: midiCC.ratio))

        // MARK: Not a cell parameter

        // Coarse tune is intentionally ignored - only fine tune is allowed.
        case .tune: return nil

        // Performance state. Not undoable, not copied, applied directly.
        case .mute, .solo, .lock: return nil

        // Master / kit-level actions, handled by the caller.
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

// MARK: BROADCAST TO SAMPLER
extension MaschineInterface {

    /// Encodes cell parameters in to Battery's CC vocabulary.
    ///
    /// Pure by construction: `static`, so it can not reach instance state or send anything. Only the case identity of each parameter is used – every value is read from `data`. That single rule is what lets composites resolve correctly: `speedCoarse` and `speedFine` each need the whole `Speed` to encode, not their own payload.
    ///
    /// - Parameters:
    ///   - parameters: the parameters to encode. Payloads are ignored.
    ///   - data: the cell's current state. The authority for every value, so it must already reflect the change being broadcast.
    ///   - channel: the cell's channel. Battery gives each cell its own.
    /// - Returns: CCs ready to send, deduped by CC number.
    static func samplerCCs(
        for parameters: [BatteryCell.Parameter],
        data: SampleCellData,
        channel: MidiChannel
    ) -> [MidiControllerChange] {
        var midiCCs = [MidiControllerChange]()
        var claimedCCNumbers = Set<MidiControlChangeNumber>()

        for parameter in parameters {
            let parameterCCs = samplerCCs(
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

    private static func samplerCCs(
        for parameter: BatteryCell.Parameter,
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

    /// Snapshots `cell` and sends the encoded result. The cell must already have
    /// the change applied.
    private func broadcastToSampler(
        _ parameters: [BatteryCell.Parameter],
        cell: BatteryCell
    ){
        guard !parameters.isEmpty else { return }
        let midiCCs = MaschineInterface.samplerCCs(
            for: parameters,
            data: cell.sampleCellData,
            channel: cell.channelIndex
        )
        sendToSampler(midiCCs: midiCCs)
    }
}

// MARK: REGISTER UNDO
extension MaschineInterface {

    /// Re-registering inside the handler is what makes redo work: `UndoManager` routes registrations to the redo stack while `isUndoing`, and back to the undo stack while `isRedoing`
    private func registerUndo(previous: [BatteryCell.Parameter], cellIndex: Int){
        guard !previous.isEmpty else { return }
        undoManager.registerUndo(withTarget: self){ maschineInterface in
            let batteryCell = maschineInterface.batteryCells[cellIndex]
            let previous = batteryCell.apply(previous)
            maschineInterface.broadcastToSampler(previous, cell: batteryCell)
            maschineInterface.registerUndo(previous: previous, cellIndex: cellIndex)
        }
    }
}

// MARK: UNDO GROUP
extension MaschineInterface {
    private func set(newUndoGroup: UndoGroup){
        if let undoGroup = undoGroup {
            if undoGroup == newUndoGroup {
                //print("SAME!")
                return
            } else {
                //print("CLOSE AND MAKE NEW")
                closeUndoGroup()
                undoManager.beginUndoGrouping()
            }
        } else {
            print("MAKE NEW!")
            undoManager.beginUndoGrouping()
        }
        self.undoGroup = newUndoGroup
    }
    private func closeUndoGroup(){
        self.undoGroup = nil
        guard undoManager.groupingLevel > 0
            else {
                print("WARNING: Attempting to close undo group when none is open.")
                return
        }
        undoManager.endUndoGrouping()
    }
}

// MARK: MASTER
extension MaschineInterface {
    private func resetAll(){
        let undoGroup = UndoGroup(task: .resetAll, sampleCellIndex: nil)
        set(newUndoGroup: undoGroup)
        for batteryCell in batteryCells {
            batteryCell.reset()
        }
        closeUndoGroup()
    }
    
    private func undo(){
        closeUndoGroup()
        undoManager.undo()
        updateController()
    }
    private func redo() {
        undoGroup = nil
        undoManager.redo()
        updateController()
    }
    
    private func copy(){
        let currentCell = batteryCells[editingCellIndex]
        self.copiedPropertyData = currentCell.copy()
    }
    private func paste(){
        guard let propertyData = self.copiedPropertyData
            else {
                print("No copied data.")
                return
        }
        let newUndoGroup = UndoGroup(
            task: .paste,
            sampleCellIndex: nil
        )
        set(newUndoGroup: newUndoGroup)
        batteryCells[editingCellIndex].paste(datas: propertyData)
        updateController()
    }
    
    private func lockAll(){
        setAllLockTo(isLocked: true)
    }
    private func unlockAll(){
        setAllLockTo(isLocked: false)
    }
    private func setAllLockTo(isLocked: Bool){
        for batteryCell in batteryCells {
            batteryCell.set(property: .lock(value: isLocked))
        }
    }
    private func unsoloAll(){
        for batteryCell in batteryCells {
            batteryCell.unsolo()
        }
    }
}

// MARK: HELPER
extension MaschineInterface {
    private var selectedCell: BatteryCell {
        return batteryCells[editingCellIndex]
    }
}



struct UndoGroup {
    //let task: MidiCCValueMap
    // Likely should be internal domain and not midi domain. but easy solution for now. 
    let task: MidiInputMapping
    let sampleCellIndex: Int?
}

extension UndoGroup: Equatable {
    static func == (lhs: UndoGroup, rhs: UndoGroup) -> Bool {
        return
            lhs.sampleCellIndex == rhs.sampleCellIndex &&
            //lhs.task.midiCCInterface == rhs.task.midiCCInterface
            lhs.task == rhs.task
    }
    
    
}
