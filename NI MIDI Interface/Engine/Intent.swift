enum Intent {
    case unsoloAll, unlockAll, lockAll, undo, redo, resetAll

    case pinSelection

    case copy(fromCellIndex: Int), paste(toCellIndex: Int)

    case mute(cellIndex: Int), solo(cellIndex: Int), lock(cellIndex: Int)

    // A little awkward since these are also cell parameters.
    case toggleTransientMaster(cellIndex: Int), toggleLofi(cellIndex: Int), toggleAmpEnvelope(cellIndex: Int)

    case reset(cellIndex: Int)
    case updateCellParameter(cellIndex: Int, parameter: Cell.Parameter)
}
