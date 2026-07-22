//
//  MaschineInterface.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation
import ReactiveSwift




class Engine {
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
    private var undoCoordinator: UndoCoordinator!

    /* private */ let midi: MIDI
    var noteObserver: Disposable?
    var keyboardNoteObserver: Disposable?
    var ccObserver: Disposable?
    var documentData: DocumentData {
        return kit.documentData
    }
    
    init(documentData: DocumentData, midi: MIDI, undoManager: UndoManager) throws {
        guard documentData.sampleCellsData.count == 16
            else { throw NSError(domain: "not 16 cells", code: 23, userInfo: nil)}
        let samplerOutputSelection = MidiOutput(
            midi: midi,
            selectedDeviceIndex: nil
        )
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

        self.undoCoordinator = UndoCoordinator(
            undoManager: undoManager,
            reapply: { [weak self] previous, cellIndex in
                self?.apply(previous, cellIndex: cellIndex)
            },
            rerender: { [weak self] in
                self?.updateController()
            }
        )

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
extension Engine {
    func dispose(){
        print("DISPOSING!!")
        undoCoordinator.removeAllActions()
        noteObserver?.dispose()
        ccObserver?.dispose()
        keyboardNoteObserver?.dispose()
    }
}

// MARK: SEND CC TO:
extension Engine {
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
extension Engine {
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
extension Engine {



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

    private func execute(_ intent: Intent){
        switch intent {
        case .unsoloAll: kit.unsoloAll()
        case .unlockAll: kit.setAllLocked(false)
        case .lockAll: kit.setAllLocked(true)
        case .undo: undoCoordinator.undo()
        case .redo: undoCoordinator.redo()
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
            undoCoordinator.beginGroup(for: intent)
            apply(Cell.defaultParameters, cellIndex: cellIndex)
            updateController()

        case .updateCellParameter(let cellIndex, let parameter):
            undoCoordinator.beginGroup(for: intent)
            apply([parameter], cellIndex: cellIndex)
        }
    }
}

// MARK: APPLY
extension Engine {

    @discardableResult
    private func apply(
        _ parameters: [Cell.Parameter],
        cellIndex: Int
    ) -> [Cell.Parameter] {
        let previous = kit.apply(parameters, cellIndex: cellIndex)
        guard !previous.isEmpty else { return [] }
        undoCoordinator.registerUndo(previous: previous, cellIndex: cellIndex)
        samplerBroadcaster.broadcast(
            previous,
            data: kit.sampleCellData(cellIndex: cellIndex),
            cellIndex: cellIndex
        )
        return previous
    }
}

// MARK: MASTER
extension Engine {
    private func resetAll(){
        undoCoordinator.beginGroup(for: .resetAll)
        for cellIndex in 0..<kit.cellCount {
            apply(Cell.defaultParameters, cellIndex: cellIndex)
        }
        undoCoordinator.close()
        updateController()
    }
    
    private func paste(){
        guard let copiedParameters = kit.copiedParameters
            else {
                print("No copied data.")
                return
        }
        undoCoordinator.beginGroup(for: .paste(toCellIndex: kit.editingCellIndex))
        apply(copiedParameters, cellIndex: kit.editingCellIndex)
        undoCoordinator.close()
        updateController()
    }
}
