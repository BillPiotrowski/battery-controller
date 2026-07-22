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
            case parameter(String)
            case reset
            case paste
            case resetAll
        }
        let task: Task
        let cellIndex: Int?
        // TODO: add a timer or something to expire this after a few moments.
    }

    static func group(for intent: Intent) -> UndoGroup? {
        switch intent {
        case .updateCellParameter(let cellIndex, let parameter):
            return UndoGroup(task: .parameter(undoName(parameter)), cellIndex: cellIndex)
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

    static func undoName(_ parameter: Cell.Parameter) -> String {
        return Mirror(reflecting: parameter).children.first?.label ?? "\(parameter)"
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
