//
//  Engine+ControlChange.swift
//  NI MIDI Interface
//
//  Created by Bill Piotrowski on 7/22/26.
//  Copyright © 2026 William Piotrowski. All rights reserved.
//

import Foundation

// MARK: MIDI CC CHANGE
extension Engine {
    func midiCCHandler(midiCC: MidiControllerChange){
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
