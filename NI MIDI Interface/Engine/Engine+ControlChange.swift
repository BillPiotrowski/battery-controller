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
        case .resetAll: apply(intent)

        case .select(_, let isLocked):
            kit.isSelectionLocked = isLocked

        case .copy(let fromCellIndex): kit.copy(cellIndex: fromCellIndex)
        case .paste: apply(intent)

        case .mute(let cellIndex, let isMuted):
            kit.setMute(isMuted, cellIndex: cellIndex)
        case .solo(let cellIndex, let isSoloed):
            kit.setSolo(isSoloed, cellIndex: cellIndex)
        case .lock(let cellIndex, let isLocked):
            kit.setLock(isLocked, cellIndex: cellIndex)

        case .reset: apply(intent)
        case .updateCellParameter: apply(intent)
        }
    }
}
