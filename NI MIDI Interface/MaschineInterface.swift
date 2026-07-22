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
    private let kit: Kit

    private let samplerBroadcaster: SamplerBroadcaster

    var samplerOutputSelection: MidiOutput {
        return samplerBroadcaster.output
    }

    private let controllerBroadcaster: ControllerBroadcaster

    var controllerOutputDevice: MidiOutput {
        return controllerBroadcaster.output
    }

    var controllerInput: MidiInput
    var keyboardInput: MidiInput
    private var undoGroup: UndoGroup?
    
    private let undoManager: UndoManager
    
    /* private */ let midi: MIDI
    var noteObserver: Disposable?
    var keyboardNoteObserver: Disposable?
    var ccObserver: Disposable?
    var documentData: DocumentData {
        return kit.documentData
    }
    
    init(documentData: DocumentData, midi: MIDI) throws {
        guard documentData.sampleCellsData.count == 16
            else { throw NSError(domain: "not 16 cells", code: 23, userInfo: nil)}
        let samplerOutputSelection = MidiOutput(
            midi: midi,
            selectedDeviceIndex: nil
        )
        let undoManager = UndoManager()
        var batteryCells = [Cell]()
        for n in 0...15 {
            let batteryCell = Cell(
                sampleCellData: documentData.sampleCellsData[n]
            )
            batteryCells.append(batteryCell)
        }

        self.samplerBroadcaster = SamplerBroadcaster(output: samplerOutputSelection)
        self.controllerBroadcaster = ControllerBroadcaster(
            output: MidiOutput(midi: midi, selectedDeviceIndex: nil)
        )
        self.controllerInput = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.keyboardInput = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.midi = midi
        self.kit = Kit(cells: batteryCells)
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
        samplerBroadcaster.broadcastAll(
            cells: kit.allSampleCellData
        )
    }

    private func updateController(){
        controllerBroadcaster.broadcastAll(
            data: kit.selectedCellData,
            selectedCellIndex: kit.editingCellIndex,
            cellCount: kit.cellCount
        )
    }
}

// MARK: MIDI NOTE CHANGE
extension MaschineInterface {
    private func midiKeyboardNoteHandler(midiNote: MIDINote){
        samplerBroadcaster.play(
            midiNote: midiNote,
            cellIndex: kit.editingCellIndex
        )
    }
    private func midiNoteHandler(midiNote: MIDINote){
        let isNoteOn = midiNote.velocity > 0 && midiNote.isNoteOn
        guard let cellIndex = midiNote.cellIndex
            else {
                print("No cell index.")
                return
        }
        if isNoteOn {
            if kit.setEditingCellIndex(cellIndex) {
                updateController()
            }
        }
        guard kit.isPlayable(cellIndex: cellIndex)
            else {
                print("CAN NOT PLAY")
                return
        }
        let pitch = kit.sampleCellData(cellIndex: cellIndex).sampleData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: isNoteOn
        )
        samplerBroadcaster.play(
            midiNote: newMidiNote,
            cellIndex: cellIndex
        )
    }
}
// MARK: MIDI CC CHANGE
extension MaschineInterface {

    enum KitIntent {
        case unsoloAll, unlockAll, lockAll, undo, redo, resetAll

        case select(cellIndex: Int, Bool)

        case copy(fromCellIndex: Int), paste(toCellIndex: Int)

        case mute(cellIndex: Int, isMuted: Bool), solo(cellIndex: Int, isSoloed: Bool), lock(cellIndex: Int, isLocked: Bool)

        case reset(cellIndex: Int)
        case updateCellParameter(cellIndex: Int, parameter: Cell.Parameter)
    }

    private func midiCCHandler(midiCC: MidiControllerChange){
        do {
            let intent = try MidiInputMapping.intent(
                from: midiCC,
                cellIndex: kit.editingCellIndex
            )
            execute(intent)
        }
        catch { print(error) }
    }

    private func execute(_ intent: KitIntent){
        switch intent {
        case .unsoloAll: kit.unsoloAll()
        case .unlockAll: kit.setAllLocked(false)
        case .lockAll: kit.setAllLocked(true)
        case .undo: undo()
        case .redo: redo()
        case .resetAll: resetAll()

        case .select(_, let isLocked):
            kit.isSelectionLocked = isLocked

        case .copy(let fromCellIndex): kit.copy(cellIndex: fromCellIndex)
        case .paste: paste()

        case .mute(let cellIndex, let isMuted):
            kit.setMute(isMuted, cellIndex: cellIndex)
        case .solo(let cellIndex, let isSoloed):
            kit.setSolo(isSoloed, cellIndex: cellIndex)
        case .lock(let cellIndex, let isLocked):
            kit.setLock(isLocked, cellIndex: cellIndex)

        case .reset(let cellIndex):
            apply(
                Cell.defaultParameters,
                cellIndex: cellIndex,
                undoGroup: UndoGroup(
                    task: "reset",
                    sampleCellIndex: cellIndex
                )
            )
            updateController()

        case .updateCellParameter(let cellIndex, let parameter):
            apply(
                [parameter],
                cellIndex: cellIndex,
                undoGroup: UndoGroup(
                    task: undoTask(for: parameter),
                    sampleCellIndex: cellIndex
                )
            )
        }
    }

    // TODO: temporary undo-grouping key. Replace in the undo refactor.
    private func undoTask(for parameter: Cell.Parameter) -> String {
        return Mirror(reflecting: parameter).children.first?.label ?? "\(parameter)"
    }
}

// MARK: APPLY
extension MaschineInterface {

    /// Pass `undoGroup` to open one, or `nil` when the caller owns the group –
    @discardableResult
    private func apply(
        _ parameters: [Cell.Parameter],
        cellIndex: Int,
        undoGroup: UndoGroup?
    ) -> [Cell.Parameter] {
        let previous = kit.apply(parameters, cellIndex: cellIndex)
        guard !previous.isEmpty else { return [] }
        if let undoGroup { set(newUndoGroup: undoGroup) }
        registerUndo(previous: previous, cellIndex: cellIndex)
        samplerBroadcaster.broadcast(
            previous,
            data: kit.sampleCellData(cellIndex: cellIndex),
            cellIndex: cellIndex
        )
        return previous
    }

    private func registerUndo(previous: [Cell.Parameter], cellIndex: Int){
        undoManager.registerUndo(withTarget: self){ maschineInterface in
            maschineInterface.apply(previous, cellIndex: cellIndex, undoGroup: nil)
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
        set(newUndoGroup: UndoGroup(task: "resetAll", sampleCellIndex: nil))
        for cellIndex in 0..<kit.cellCount {
            apply(
                Cell.defaultParameters,
                cellIndex: cellIndex,
                undoGroup: nil
            )
        }
        closeUndoGroup()
        updateController()
    }
    
    private func undo(){
        closeUndoGroup()
        undoManager.undo()
        updateController()
    }
    // Symmetric with undo() - leaving a group open here nests the next one.
    private func redo(){
        closeUndoGroup()
        undoManager.redo()
        updateController()
    }
    
    private func paste(){
        guard let copiedParameters = kit.copiedParameters
            else {
                print("No copied data.")
                return
        }
        set(newUndoGroup: UndoGroup(task: "paste", sampleCellIndex: nil))
        apply(copiedParameters, cellIndex: kit.editingCellIndex, undoGroup: nil)
        closeUndoGroup()
        updateController()
    }
}



struct UndoGroup: Equatable {
    let task: String
    let sampleCellIndex: Int?
}
