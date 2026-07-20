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
    private func midiCCHandler(midiCC: MidiControllerChange){
        do {
            let sampleProperty = try MidiCCInterface(inputNumber: midiCC.ccNumber)


            
            
            let batteryCell = batteryCells[editingCellIndex]

            switch sampleProperty.destination {
            case
                .sampleCellProperty,
                .ampEnvelope,
                .loFi,
                .sampleData:
                
                let newUndoGroup = UndoGroup(
                    task: sampleProperty,
                    sampleCellIndex: editingCellIndex
                )
                set(newUndoGroup: newUndoGroup)
                
                
                
                 batteryCell.update(
                    midiCC: midiCC,
                    destination: sampleProperty.destination
                )
            case .sampleCellState:

                let newMidiCC = try MidiCCValueMap(midiCCInterface: sampleProperty, midiCC: midiCC)
                batteryCell.setStateFrom(midiCC: newMidiCC)
            case .master:

                let newMidiCC = try MidiCCValueMap(midiCCInterface: sampleProperty, midiCC: midiCC)
                self.handleMasterCC(midiCC: newMidiCC)
            }
        }
        catch { print(error) }
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
    private func handleMasterCC(midiCC: MidiCCValueMap){
        guard case .master = midiCC.midiCCInterface.destination
            else {
                print("WARNING: Midi CC not a master setting.")
                return
        }
        switch midiCC {
        case .unsoloAll: self.unsoloAll()
        case .unlockAll: self.unlockAll()
        case .lockAll: self.lockAll()
        case .isSelectionLocked(let value): self.isSelectionLocked = value
        case .copy: self.copy()
        case .paste: self.paste()
        case .undo: self.undo()
        case .redo: self.redo()
        case .resetAll: self.resetAll()
        default:
            print("WARNING: MIDI CC: \(midiCC) not handled.")
        }
    }
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
    let task: MidiCCInterface
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
