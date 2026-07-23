import Foundation

class Kit {
    private let cells: [Cell]
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

    var selectedCellData: SampleCellData {
        return cells[editingCellIndex].sampleCellData
    }

    func sampleCellData(cellIndex: Int) -> SampleCellData {
        return cells[cellIndex].sampleCellData
    }

    var allSampleCellData: [SampleCellData] {
        return cells.map { $0.sampleCellData }
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

    func isEditable(cellIndex: Int) -> Bool {
        return cells[cellIndex].isEditable
    }

    var documentData: DocumentData {
        return DocumentData(sampleCellsData: allSampleCellData)
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

    func toggleSelectionLock() -> Bool {
        isSelectionLocked.toggle()
        return isSelectionLocked
    }
}

// MARK: PERFORMANCE STATE
extension Kit {
    func toggleMute(cellIndex: Int) -> Bool {
        let isMuted = !cells[cellIndex].stateData.mute
        cells[cellIndex].stateData.mute = isMuted
        return isMuted
    }
    
    func toggleSolo(cellIndex: Int) -> Bool {
        let isSoloed = !cells[cellIndex].stateData.solo
        cells[cellIndex].stateData.solo = isSoloed
        return isSoloed
    }
    
    func toggleLock(cellIndex: Int) -> Bool {
        let isLocked = !cells[cellIndex].stateData.lock
        cells[cellIndex].stateData.lock = isLocked
        return isLocked
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

// MARK: MUTATE
extension Kit {
    func apply(_ parameters: [Cell.Parameter], cellIndex: Int) -> [Cell.Parameter] {
        return cells[cellIndex].apply(parameters)
    }
}
