import Foundation
import ReactiveSwift

class Engine {
    let kit: Kit

    let samplerBroadcaster: SamplerBroadcaster

    var samplerOutputSelection: MidiOutput {
        return samplerBroadcaster.output
    }

    let controllerBroadcaster: ControllerBroadcaster

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

    func applyUndoable(_ intent: Intent) {
        let applications: [(parameters: [Cell.Parameter], cellIndex: Int)]

        switch intent {
        case .updateCellParameter(let cellIndex, let parameter):
            applications = [(parameters: [parameter], cellIndex: cellIndex)]
        case .reset(let cellIndex):
            applications = [(parameters: Cell.defaultParameters, cellIndex: cellIndex)]
        case .paste:
            guard let copiedParameters = kit.copiedParameters else {
                print("No copied data.")
                return
            }
            applications = [(parameters: copiedParameters, cellIndex: kit.editingCellIndex)]
        case .resetAll:
            applications = (0..<kit.cellCount).map {
                (parameters: Cell.defaultParameters, cellIndex: $0)
            }
        default:
            return
        }

        undoCoordinator.beginGroup(for: intent)
        // A locked cell rejects edits here. Undo/redo bypass this path (they go
        // straight to the private apply), so history can still restore a cell
        // that was edited and then locked.
        /// This is currently handled by the placement, but we may want to add a property `respectsLock` on the Intent
        for application in applications where kit.isEditable(cellIndex: application.cellIndex) {
            apply(application.parameters, cellIndex: application.cellIndex)
        }
        if !intent.isContinuous { undoCoordinator.close() }
        if intent.requiresCompleteControllerRefresh { updateController() }
    }

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
        // possibly broadcast filtered back to sampler? if we make mute / solo / etc parameters.
        return previous
    }
}
