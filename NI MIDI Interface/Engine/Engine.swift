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
    let kit: Kit

    let samplerBroadcaster: SamplerBroadcaster

    var samplerOutputSelection: MidiOutput {
        return samplerBroadcaster.output
    }

    private let controllerBroadcaster: ControllerBroadcaster

    var controllerOutputDevice: MidiOutput {
        return controllerBroadcaster.output
    }

    var controllerInput: MidiInput
    var keyboardInput: MidiInput
    var undoCoordinator: UndoCoordinator!

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

    func updateController(){
        controllerBroadcaster.broadcastAll(
            data: kit.selectedCellData,
            selectedCellIndex: kit.editingCellIndex,
            cellCount: kit.cellCount
        )
    }
}

// MARK: APPLY
extension Engine {

    @discardableResult
    func apply(
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
    func resetAll(){
        undoCoordinator.beginGroup(for: .resetAll)
        for cellIndex in 0..<kit.cellCount {
            apply(Cell.defaultParameters, cellIndex: cellIndex)
        }
        undoCoordinator.close()
        updateController()
    }
    
    func paste(){
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
