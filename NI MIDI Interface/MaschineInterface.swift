//
//  MaschineInterface.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation
import ReactiveSwift




class MaschineInterface {
    private var editingCellIndex: Int

    private let samplerBroadcaster: SamplerBroadcaster

    var samplerOutputSelection: MidiOutput {
        return samplerBroadcaster.output
    }

    private let controllerBroadcaster: ControllerBroadcaster

    var controllerOutputDevice: MidiOutput {
        return controllerBroadcaster.output
    }

    var controllerInput: MidiInput
    var keyboardInput: MidiInput
    private var undoGroup: UndoGroup?
    
    private let undoManager: UndoManager
    
    private var isSelectionLocked: Bool
    
    // Is there a way to store this to a clipboard?
    private var copiedParameters: [BatteryCell.Parameter]?
    
    /* private */ let midi: MIDI
    private let batteryCells: [BatteryCell]
    var noteObserver: Disposable?
    var keyboardNoteObserver: Disposable?
    var ccObserver: Disposable?
    var documentData: DocumentData {
        var sampleCellsData = [SampleCellData]()
        for sampleCell in batteryCells {
            sampleCellsData.append(sampleCell.sampleCellData)
        }
        return DocumentData(sampleCellsData: sampleCellsData)
    }
    
    init(documentData: DocumentData, midi: MIDI) throws {
        guard documentData.sampleCellsData.count == 16
            else { throw NSError(domain: "not 16 cells", code: 23, userInfo: nil)}
        let samplerOutputSelection = MidiOutput(
            midi: midi,
            selectedDeviceIndex: nil
        )
        let undoManager = UndoManager()
        var batteryCells = [BatteryCell]()
        for n in 0...15 {
            let batteryCell = BatteryCell(
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
        self.editingCellIndex = 0
        self.midi = midi
        self.batteryCells = batteryCells
        self.isSelectionLocked = false
        self.undoManager = undoManager
        
        self.undoManager.groupsByEvent = false
        
        
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
extension MaschineInterface {
    func dispose(){
        print("DISPOSING!!")
        noteObserver?.dispose()
        ccObserver?.dispose()
        keyboardNoteObserver?.dispose()
    }
}

// MARK: SEND CC TO:
extension MaschineInterface {
    private func sendAll(){
        samplerBroadcaster.broadcastAll(
            cells: batteryCells.map { $0.sampleCellData }
        )
    }

    private func updateController(){
        controllerBroadcaster.broadcastAll(
            data: selectedCell.sampleCellData,
            selectedCellIndex: editingCellIndex,
            cellCount: batteryCells.count
        )
    }
}

// MARK: CELL INDEX
extension MaschineInterface {
    private func setEditingCellIndex(cellIndex: Int){
        guard !isSelectionLocked
            else {
                //print("WARNING: Can not check selection because it is locked.")
                return
        }
        guard editingCellIndex != cellIndex
            else {
                //print("SAME INDEX")
                return
        }
        self.editingCellIndex = cellIndex
        updateController()
    }
}

// MARK: MIDI NOTE CHANGE
extension MaschineInterface {
    private func midiKeyboardNoteHandler(midiNote: MIDINote){
        samplerBroadcaster.play(
            midiNote: midiNote,
            cellIndex: editingCellIndex
        )
    }
    private func midiNoteHandler(midiNote: MIDINote){
        let isNoteOn = midiNote.velocity > 0 && midiNote.isNoteOn
        guard let cellIndex = midiNote.cellIndex
            else {
                print("No cell index.")
                return
        }
        if isNoteOn {
            setEditingCellIndex(cellIndex: cellIndex)
        }
        guard isPlayable(batteryCell: batteryCells[cellIndex])
            else {
                print("CAN NOT PLAY")
                return
        }
        let pitch = batteryCells[cellIndex].sampleCellData.sampleData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: isNoteOn
        )
        samplerBroadcaster.play(
            midiNote: newMidiNote,
            cellIndex: cellIndex
        )
    }
    // MORE EFFICIENT WAY OF DOING THIS??
    private var isAnySoloed: Bool {
        for cell in batteryCells {
            if cell.isSoloed {
                return true
            }
        }
        return false
    }
    private func isPlayable(batteryCell: BatteryCell) -> Bool {
        if batteryCell.isMuted { return false }
        if isAnySoloed { return batteryCell.isSoloed }
        return true
    }
}
// MARK: MIDI CC CHANGE
extension MaschineInterface {

  enum RouterError: ScorepioError {
      case unmappedCC(MidiControlChangeNumber)
  
      var message: String {
          switch self {
          case .unmappedCC(let n): return "No input mapping for CC \(n)."
          }
      }
  }

    enum KitIntent {
        case unsoloAll, unlockAll, lockAll, undo, redo, resetAll

        case select(cellIndex: Int, Bool)

        case copy(fromCellIndex: Int), paste(toCellIndex: Int)

        case mute(cellIndex: Int, isMuted: Bool), solo(cellIndex: Int, isSoloed: Bool), lock(cellIndex: Int, isLocked: Bool)

        case reset(cellIndex: Int)
        case updateCellParameter(cellIndex: Int, parameter: BatteryCell.Parameter)
    }

    private func midiCCHandler(midiCC: MidiControllerChange){
        do {
            guard let sampleProperty = MidiInputMapping(rawValue: midiCC.ccNumber) else {
                throw RouterError.unmappedCC(midiCC.ccNumber)
            }
            
            // TODO: these switches end in `default: break`, so a new
            // MidiInputMapping case falls through silently

            // MASTER
            switch sampleProperty {
            case .unsoloAll:
                guard midiCC.bool else { return }
                self.unsoloAll()
                return
            case .unlockAll:
                guard midiCC.bool else { return }
                self.unlockAll()
                return
            case .lockAll:
                guard midiCC.bool else { return }
                self.lockAll()
                return
//            case .isSelectionLocked(let value): self.isSelectionLocked = value
            case .copy:
                guard midiCC.bool else { return }
                self.copy()
                return
            case .paste:
                guard midiCC.bool else { return }
                self.paste()
                return
            case .undo:
                guard midiCC.bool else { return }
                self.undo()
                return
            case .redo:
                guard midiCC.bool else { return }
                self.redo()
                return
            case .resetAll:
                guard midiCC.bool else { return }
                self.resetAll()
                return

            case .select:
                self.isSelectionLocked = midiCC.bool
                return
                
            default: break
            }
            
            // does this require a guard?
            let batteryCell = batteryCells[editingCellIndex]
            
            
            switch sampleProperty {
            case .mute:
                batteryCell.stateData.mute = midiCC.bool
                return
            case .solo:
                batteryCell.stateData.solo = midiCC.bool
                return
            case .lock:
                batteryCell.stateData.lock = midiCC.bool
                return
            case .reset:
                guard midiCC.bool else { return }
                apply(
                    BatteryCell.defaultParameters,
                    cellIndex: editingCellIndex,
                    undoGroup: UndoGroup(
                        task: .reset,
                        sampleCellIndex: editingCellIndex
                    )
                )
                updateController()
                return

            default: break
            }

            guard let change = MidiInputMapping.parameter(mapping: sampleProperty, midiCC: midiCC) else {
                // Add warning.
                return
            }

            apply(
                [change],
                cellIndex: editingCellIndex,
                undoGroup: UndoGroup(
                    task: sampleProperty,
                    sampleCellIndex: editingCellIndex
                )
            )
        }
        catch { print(error) }
    }
}

// MARK: APPLY
extension MaschineInterface {

    /// Pass `undoGroup` to open one, or `nil` when the caller owns the group –
    @discardableResult
    private func apply(
        _ parameters: [BatteryCell.Parameter],
        cellIndex: Int,
        undoGroup: UndoGroup?
    ) -> [BatteryCell.Parameter] {
        let batteryCell = batteryCells[cellIndex]
        let previous = batteryCell.apply(parameters)
        guard !previous.isEmpty else { return [] }
        if let undoGroup { set(newUndoGroup: undoGroup) }
        registerUndo(previous: previous, cellIndex: cellIndex)
        samplerBroadcaster.broadcast(
            previous,
            data: batteryCell.sampleCellData,
            cellIndex: cellIndex
        )
        return previous
    }

    private func registerUndo(previous: [BatteryCell.Parameter], cellIndex: Int){
        undoManager.registerUndo(withTarget: self){ maschineInterface in
            maschineInterface.apply(previous, cellIndex: cellIndex, undoGroup: nil)
        }
    }
}

// MARK: UNDO GROUP
extension MaschineInterface {
    private func set(newUndoGroup: UndoGroup){
        if let undoGroup = undoGroup {
            if undoGroup == newUndoGroup {
                //print("SAME!")
                return
            } else {
                //print("CLOSE AND MAKE NEW")
                closeUndoGroup()
                undoManager.beginUndoGrouping()
            }
        } else {
            print("MAKE NEW!")
            undoManager.beginUndoGrouping()
        }
        self.undoGroup = newUndoGroup
    }
    private func closeUndoGroup(){
        self.undoGroup = nil
        guard undoManager.groupingLevel > 0
            else {
                print("WARNING: Attempting to close undo group when none is open.")
                return
        }
        undoManager.endUndoGrouping()
    }
}

// MARK: MASTER
extension MaschineInterface {
    private func resetAll(){
        set(newUndoGroup: UndoGroup(task: .resetAll, sampleCellIndex: nil))
        for cellIndex in batteryCells.indices {
            apply(
                BatteryCell.defaultParameters,
                cellIndex: cellIndex,
                undoGroup: nil
            )
        }
        closeUndoGroup()
        updateController()
    }
    
    private func undo(){
        closeUndoGroup()
        undoManager.undo()
        updateController()
    }
    // Symmetric with undo() - leaving a group open here nests the next one.
    private func redo(){
        closeUndoGroup()
        undoManager.redo()
        updateController()
    }
    
    private func copy(){
        self.copiedParameters = batteryCells[editingCellIndex].allParameters
    }
    private func paste(){
        guard let copiedParameters = self.copiedParameters
            else {
                print("No copied data.")
                return
        }
        set(newUndoGroup: UndoGroup(task: .paste, sampleCellIndex: nil))
        apply(copiedParameters, cellIndex: editingCellIndex, undoGroup: nil)
        closeUndoGroup()
        updateController()
    }
    
    private func lockAll(){
        setAllLockTo(isLocked: true)
    }
    private func unlockAll(){
        setAllLockTo(isLocked: false)
    }
    private func setAllLockTo(isLocked: Bool){
        for batteryCell in batteryCells {
            batteryCell.set(property: .lock(value: isLocked))
        }
    }
    private func unsoloAll(){
        for batteryCell in batteryCells {
            batteryCell.unsolo()
        }
    }
}

// MARK: HELPER
extension MaschineInterface {
    private var selectedCell: BatteryCell {
        return batteryCells[editingCellIndex]
    }
}



struct UndoGroup {
    //let task: MidiCCValueMap
    // Likely should be internal domain and not midi domain. but easy solution for now. 
    let task: MidiInputMapping
    let sampleCellIndex: Int?
}

extension UndoGroup: Equatable {
    static func == (lhs: UndoGroup, rhs: UndoGroup) -> Bool {
        return
            lhs.sampleCellIndex == rhs.sampleCellIndex &&
            //lhs.task.midiCCInterface == rhs.task.midiCCInterface
            lhs.task == rhs.task
    }
    
    
}
