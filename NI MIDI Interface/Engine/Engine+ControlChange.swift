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
        case .resetAll: applyUndoable(intent)

        case .pinSelection:
            kit.toggleSelectionLock()

        case .copy(let fromCellIndex): kit.copy(cellIndex: fromCellIndex)
        case .paste: applyUndoable(intent)

        // Performance state: flip, then push the new state to light the LED.
        case .mute(let cellIndex):
            kit.toggleMute(cellIndex: cellIndex)
            updateController()
        case .solo(let cellIndex):
            kit.toggleSolo(cellIndex: cellIndex)
            updateController()
        case .lock(let cellIndex):
            kit.toggleLock(cellIndex: cellIndex)
            updateController()

        // Enable toggles: read current state, apply the inverse as an undoable
        // parameter edit, then push it back to the controller.
        case .toggleTransientMaster(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).propertyData.enableTransientMaster
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableTransientMaster(!isEnabled)))
            updateController()
        case .toggleLofi(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).loFiData.enable
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableLofi(!isEnabled)))
            updateController()
        case .toggleAmpEnvelope(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).ampEnvelopeData.enableAmpEnv
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableAmpEnvelope(!isEnabled)))
            updateController()

        case .reset: applyUndoable(intent)
        case .updateCellParameter: applyUndoable(intent)
        }
    }
}
