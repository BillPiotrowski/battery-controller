import Foundation

final class UndoCoordinator {
    private weak var undoManager: UndoManager?
    private var group: UndoGroup?
    private let reapply: ([Cell.Parameter], Int) -> Void
    private let rerender: () -> Void

    init(
        undoManager: UndoManager?,
        reapply: @escaping ([Cell.Parameter], Int) -> Void,
        rerender: @escaping () -> Void
    ){
        self.undoManager = undoManager
        self.reapply = reapply
        self.rerender = rerender
        undoManager?.groupsByEvent = false
    }
}

// MARK: KEY
private extension UndoCoordinator {
    struct UndoGroup: Equatable {
        enum Task: Equatable {
            case parameter(ParameterKey)
            case reset
            case paste
            case resetAll
        }
        let task: Task
        let cellIndex: Int?
        // TODO: add a timer or something to expire this after a few moments.
    }

    // Unique Id to be applied to Cell.Parameter so it can generate unique undo group names.
    enum ParameterKey: Equatable {
        // Property
        case start1, start2, volume, pan, speedCoarse, speedFine,
            filterLow, filterHigh, transientAttack, transientSustain,
            enableTransientMaster, fineTune, reverbSend, delaySend,
            velocity, envOrder, formant, loopStart, loopStartFine,
            loopLength, loopLengthFine

        // Amp Envelope
        case attack, hold, decay, sustain, release, enableAmpEnvelope

        // Lo-Fi
        case lofiBits, lofiHertz, lofiNoise, lofiColor, lofiOut, enableLofi

        // Sample
        case pitch
    }

    static func group(for intent: Intent) -> UndoGroup? {
        switch intent {
        case .updateCellParameter(let cellIndex, let parameter):
            return UndoGroup(task: .parameter(key(for: parameter)), cellIndex: cellIndex)
        case .reset(let cellIndex):
            return UndoGroup(task: .reset, cellIndex: cellIndex)
        case .paste:
            return UndoGroup(task: .paste, cellIndex: nil)
        case .resetAll:
            return UndoGroup(task: .resetAll, cellIndex: nil)
        default:
            return nil
        }
    }

    static func key(for parameter: Cell.Parameter) -> ParameterKey {
        switch parameter {
        // Property
        case .start1: return .start1
        case .start2: return .start2
        case .volume: return .volume
        case .pan: return .pan
        case .speedCoarse: return .speedCoarse
        case .speedFine: return .speedFine
        case .filterLow: return .filterLow
        case .filterHigh: return .filterHigh
        case .transientAttack: return .transientAttack
        case .transientSustain: return .transientSustain
        case .enableTransientMaster: return .enableTransientMaster
        case .fineTune: return .fineTune
        case .reverbSend: return .reverbSend
        case .delaySend: return .delaySend
        case .velocity: return .velocity
        case .envOrder: return .envOrder
        case .formant: return .formant
        case .loopStart: return .loopStart
        case .loopStartFine: return .loopStartFine
        case .loopLength: return .loopLength
        case .loopLengthFine: return .loopLengthFine

        // Amp Envelope
        case .attack: return .attack
        case .hold: return .hold
        case .decay: return .decay
        case .sustain: return .sustain
        case .release: return .release
        case .enableAmpEnvelope: return .enableAmpEnvelope

        // Lo-Fi
        case .lofiBits: return .lofiBits
        case .lofiHertz: return .lofiHertz
        case .lofiNoise: return .lofiNoise
        case .lofiColor: return .lofiColor
        case .lofiOut: return .lofiOut
        case .enableLofi: return .enableLofi

        // Sample
        case .pitch: return .pitch
        }
    }
}

// MARK: GROUPING
extension UndoCoordinator {
    func beginGroup(for intent: Intent) {
        guard let newGroup = UndoCoordinator.group(for: intent) else { return }
        set(newGroup)
    }

    private func set(_ newGroup: UndoGroup) {
        if let group = group {
            if group == newGroup {
                return
            } else {
                close()
                undoManager?.beginUndoGrouping()
            }
        } else {
            undoManager?.beginUndoGrouping()
        }
        self.group = newGroup
    }

    func close() {
        self.group = nil
        guard let undoManager, undoManager.groupingLevel > 0
            else {
                print("WARNING: Attempting to close undo group when none is open.")
                return
        }
        undoManager.endUndoGrouping()
    }
}

// MARK: REGISTER / PERFORM
extension UndoCoordinator {
    func registerUndo(previous: [Cell.Parameter], cellIndex: Int) {
        undoManager?.registerUndo(withTarget: self) { coordinator in
            coordinator.reapply(previous, cellIndex)
        }
    }

    func undo() {
        close()
        undoManager?.undo()
        rerender()
    }
    // Symmetric with undo() - leaving a group open here nests the next one.
    func redo() {
        close()
        undoManager?.redo()
        rerender()
    }

    func removeAllActions() {
        undoManager?.removeAllActions(withTarget: self)
    }
}
