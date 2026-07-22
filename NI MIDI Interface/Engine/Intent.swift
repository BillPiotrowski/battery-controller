//
//  Intent.swift
//  NI MIDI Interface
//
//  Created by Bill Piotrowski on 7/22/26.
//  Copyright © 2026 William Piotrowski. All rights reserved.
//

enum Intent {
    case unsoloAll, unlockAll, lockAll, undo, redo, resetAll

    case select(cellIndex: Int, Bool)

    case copy(fromCellIndex: Int), paste(toCellIndex: Int)

    case mute(cellIndex: Int, isMuted: Bool), solo(cellIndex: Int, isSoloed: Bool), lock(cellIndex: Int, isLocked: Bool)

    case reset(cellIndex: Int)
    case updateCellParameter(cellIndex: Int, parameter: Cell.Parameter)
}
