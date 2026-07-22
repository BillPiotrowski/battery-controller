import Foundation

class Kit {
    // TODO this should be private.
    let cells: [Cell]
    private(set) var editingCellIndex: Int
    var isSelectionLocked: Bool
    // Is there an OS level clipboard that can / should be used?
    private(set) var copiedParameters: [Cell.Parameter]?

    init(cells: [Cell]){
        self.cells = cells
        self.editingCellIndex = 0
        self.isSelectionLocked = false
        self.copiedParameters = nil
    }
}

// MARK: QUERY
extension Kit {
    var cellCount: Int {
        return cells.count
    }

    var selectedCell: Cell {
        return cells[editingCellIndex]
    }

    var isAnySoloed: Bool {
        for cell in cells {
            if cell.isSoloed {
                return true
            }
        }
        return false
    }

    func isPlayable(cellIndex: Int) -> Bool {
        let cell = cells[cellIndex]
        if cell.isMuted { return false }
        if isAnySoloed { return cell.isSoloed }
        return true
    }

    var documentData: DocumentData {
        return DocumentData(sampleCellsData: cells.map { $0.sampleCellData })
    }
}

// MARK: SELECTION
extension Kit {
    @discardableResult
    func setEditingCellIndex(_ cellIndex: Int) -> Bool {
        guard !isSelectionLocked else { return false }
        guard editingCellIndex != cellIndex else { return false }
        editingCellIndex = cellIndex
        return true
    }
}

// MARK: PERFORMANCE STATE
// TODO IMPORTANT: These need to be migrated to toggles.
extension Kit {
    func setMute(_ isMuted: Bool, cellIndex: Int) {
        cells[cellIndex].stateData.mute = isMuted
    }
    func setSolo(_ isSoloed: Bool, cellIndex: Int) {
        cells[cellIndex].stateData.solo = isSoloed
    }
    func setLock(_ isLocked: Bool, cellIndex: Int) {
        cells[cellIndex].stateData.lock = isLocked
    }
    func unsoloAll() {
        for cell in cells {
            cell.unsolo()
        }
    }
    func setAllLocked(_ isLocked: Bool) {
        for cell in cells {
            cell.set(property: .lock(value: isLocked))
        }
    }
}

// MARK: CLIPBOARD
extension Kit {
    func copy(cellIndex: Int) {
        copiedParameters = cells[cellIndex].allParameters
    }
}
