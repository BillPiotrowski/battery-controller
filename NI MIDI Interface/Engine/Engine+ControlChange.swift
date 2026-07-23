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
        case .unsoloAll:
            kit.unsoloAll()
            // could probably force solo to false
            controllerBroadcaster.sendSolo(kit.selectedCellData.stateData.solo)
        case .unlockAll:
            kit.setAllLocked(false)
            // could probably force lock to false
            controllerBroadcaster.sendLock(kit.selectedCellData.stateData.lock)
        case .lockAll:
            kit.setAllLocked(true)
            // could probably force lock to true
            controllerBroadcaster.sendLock(kit.selectedCellData.stateData.lock)
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
        // parameter edit, then echo the *actual* resulting state - a locked cell
        // rejects the edit, so the LED must reflect what stuck, not the target.
        case .toggleTransientMaster(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).propertyData.enableTransientMaster
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableTransientMaster(!isEnabled)))
            controllerBroadcaster.sendTransientMaster(kit.sampleCellData(cellIndex: cellIndex).propertyData.enableTransientMaster)
        case .toggleLofi(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).loFiData.enable
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableLofi(!isEnabled)))
            controllerBroadcaster.sendLofi(kit.sampleCellData(cellIndex: cellIndex).loFiData.enable)
        case .toggleAmpEnvelope(let cellIndex):
            let isEnabled = kit.sampleCellData(cellIndex: cellIndex).ampEnvelopeData.enableAmpEnv
            applyUndoable(.updateCellParameter(cellIndex: cellIndex, parameter: .enableAmpEnvelope(!isEnabled)))
            controllerBroadcaster.sendAmpEnvelope(kit.sampleCellData(cellIndex: cellIndex).ampEnvelopeData.enableAmpEnv)

        case .reset: applyUndoable(intent)
        case .updateCellParameter: applyUndoable(intent)
        }
    }
}
