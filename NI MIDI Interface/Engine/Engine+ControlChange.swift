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
            controllerBroadcaster.sendPinSelection(kit.toggleSelectionLock())

        case .copy(let fromCellIndex): kit.copy(cellIndex: fromCellIndex)
        case .paste: applyUndoable(intent)

        // Performance state: flip, then push the new state to light the LED.
        case .mute(let cellIndex):
            let isMuted = kit.toggleMute(cellIndex: cellIndex)
            controllerBroadcaster.sendMute(isMuted)
        case .solo(let cellIndex):
            let isSoloed = kit.toggleSolo(cellIndex: cellIndex)
            controllerBroadcaster.sendSolo(isSoloed)
        case .lock(let cellIndex):
            let isLocked = kit.toggleLock(cellIndex: cellIndex)
            controllerBroadcaster.sendLock(isLocked)

        // Enable toggles: read current state, apply the inverse as an undoable
        // parameter edit, then push it back to the controller.
        case .toggleTransientMaster(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).propertyData.enableTransientMaster
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableTransientMaster(!isEnabled)))
            controllerBroadcaster.sendTransientMaster(!isEnabled)
        case .toggleLofi(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).loFiData.enable
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableLofi(!isEnabled)))
            controllerBroadcaster.sendLofi(!isEnabled)
        case .toggleAmpEnvelope(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).ampEnvelopeData.enableAmpEnv
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableAmpEnvelope(!isEnabled)))
            controllerBroadcaster.sendAmpEnvelope(!isEnabled)

        case .reset: applyUndoable(intent)
        case .updateCellParameter: applyUndoable(intent)
        }
    }
}
