//
//  MaschineInterface.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import ReactiveSwift

import MIKMIDI



class MaschineInterface {
    private var editingCellIndex: Int
    
    //var samplerOutput: MidiDevice?
    var samplerOutputSelection: MidiDeviceSelection
    
    
    //var samplerOutput: MidiDevice?
    var controllerOutputDevice: MidiDeviceSelection
    var controllerSourceSelection: MidiInput
    var keyboardSourceSelection: MidiInput
    
    /*
    func setSamplerOutput(name: String){
        let midiDevice = midi.midiOutputDevices.value.first(where: {$0.name == name})
        samplerOutput = midiDevice
    }
    */
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
        //let midi = MIDI()
        
        let samplerOutputSelection = MidiDeviceSelection(
            midi: midi,
            midiDevices: midi.midiOutputDevices.value,
            selectedDeviceIndex: nil
        )
        
        var batteryCells = [BatteryCell]()
        for n in 0...15 {
            let batteryCell = BatteryCell(sampleCellData: documentData.sampleCellsData[n], midi: midi, channelIndex: n, samplerOutputSelection: samplerOutputSelection)
            batteryCells.append(batteryCell)
            print(n)
        }
        
        self.samplerOutputSelection = samplerOutputSelection
        self.controllerOutputDevice = MidiDeviceSelection(midi: midi, midiDevices: midi.midiOutputDevices.value, selectedDeviceIndex: nil)
        self.controllerSourceSelection = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.keyboardSourceSelection = MidiInput(midi: midi, selectedDeviceIndex: nil)
        self.editingCellIndex = 0
        self.midi = midi
        self.batteryCells = batteryCells
        
        
        
        self.noteObserver = controllerSourceSelection.midiNoteObserver.observe(Signal<MIDINote, Never>.Observer(
            value: self.midiNoteHandler(midiNote:),
            failed: {error in},
            completed: {},
            interrupted: {}))
        
        self.keyboardNoteObserver = keyboardSourceSelection.midiNoteObserver.observe(Signal<MIDINote, Never>.Observer(
            value: self.midiKeyboardNoteHandler(midiNote:),
            failed: {error in},
            completed: {},
            interrupted: {}))
        
        self.ccObserver = controllerSourceSelection.midiCCObserver.observe(Signal<MidiControllerChange, Never>.Observer(value: self.midiCCHandler(midiCC:), failed: {error in}, completed: {}, interrupted: {}))
        sendAll()
        updateController()
    }
    
    func dispose(){
        print("DISPOSING!!")
        noteObserver?.dispose()
        ccObserver?.dispose()
    }
    
    deinit{
        print("DEINIT!!")
        noteObserver?.dispose()
        ccObserver?.dispose()
    }
    
    private func sendAll(){
        for sampleCell in batteryCells {
            let midiEnums = sampleCell.sampleCellData.getAllMidiCCs(channel: sampleCell.channelIndex)
            var midiCCs = [MidiControllerChange]()
            for midiEnum in midiEnums {
                guard let number = midiEnum.midiCCInterface.midiCCOutputNumber
                    else { continue }
                let midiCC = MidiControllerChange(ccNumber: number, value: midiEnum.midiCCValue, channel: sampleCell.channelIndex)
                midiCCs.append(midiCC)
            }
            guard let selectedDevice = self.samplerOutputSelection.selectedMidiDevice
                else {
                    print("NO DEVICE")
                    return
            }
            do {
                try midi.send(midiCCs: midiCCs, devices: [selectedDevice])
            } catch {
                print("ERROR!")
            }
        }
        
    }
    
    private func updateController(){
        let selectedSampleCell = batteryCells[editingCellIndex]
        let midiEnums = selectedSampleCell.sampleCellData.getAllMidiCCs(channel: selectedSampleCell.channelIndex)
        for midiEnum in midiEnums {
            
        }
    }
    
    private func setEditingCellIndex(cellIndex: Int){
        /*
        guard let editingCellIndex = editingCellIndex
            else {
                self.editingCellIndex = cellIndex
                return
        }
 */
        guard editingCellIndex != cellIndex
            else {
                print("SAME INDEX")
                return
        }
        print("NEW CELL! \(cellIndex)")
        self.editingCellIndex = cellIndex
        guard let controllerDevice = controllerOutputDevice.selectedMidiDevice
            else {
                print("NO CONTROLLER SET")
                return
        }
        do {
            try batteryCells[cellIndex].sendToMaschine(controllerDevice: controllerDevice)
        } catch {
            print(error)
        }
        
        
    }
}

// MARK: MIDI NOTE CHANGE
extension MaschineInterface {
    private func midiKeyboardNoteHandler(midiNote: MIDINote){
        print(midiNote)
        
        guard let samplerOutputDevice = samplerOutputSelection.selectedMidiDevice
            else {
                print("Could not play midi note because no device is selected.")
                return
        }
        do {
            try
            midi.sendMidiNote(midiNote: midiNote, channel: editingCellIndex, devices: [samplerOutputDevice])
        } catch {
            print(error)
        }
        
    }
    private func midiNoteHandler(midiNote: MIDINote){
        guard let cellIndex = midiNote.cellIndex
            else {
                print("No cell index.")
                return
        }
        if midiNote.velocity > 0 {
            setEditingCellIndex(cellIndex: cellIndex)
        }
        //print("CELL INDEX: \(cellIndex)")
        let pitch = batteryCells[cellIndex].sampleCellData.pitch
        let newMidiNote = MIDINote(
            noteNumber: pitch.noteNumber,
            velocity: midiNote.velocity, isNoteOn: midiNote.isNoteOn
        )
        //let channel = cellIndex + 1
        guard let samplerOutputDevice = samplerOutputSelection.selectedMidiDevice
            else {
                print("Could not play midi note because no device is selected.")
                return
        }
        do {
            try
            midi.sendMidiNote(midiNote: newMidiNote, channel: cellIndex, devices: [samplerOutputDevice])
        } catch {
            print(error)
        }
        
    }
}
// MARK: MIDI CC CHANGE
extension MaschineInterface {
    private func midiCCHandler(midiCC: MidiControllerChange){
        /*
        guard let editingCellIndex = editingCellIndex
            else {
                print("NO CELL INDEX!")
                return
        }
 */
        do {
            
            let sampleProperty = try MidiCCInterface(inputNumber: midiCC.ccNumber)
            let newMidiCC = try MidiCC(midiCCInterface: sampleProperty, midiCC: midiCC)
            
            
            let samplerDestinations: [MidiDevice]?
            if let samplerOutput = samplerOutputSelection.selectedMidiDevice {
                samplerDestinations = [samplerOutput]
            } else {
                samplerDestinations = nil
            }
            
            print("GOOD: \(sampleProperty), OUTPUT NAME: \(samplerDestinations)")
            
            let batteryCell = batteryCells[editingCellIndex]
            batteryCell.set(
                midiCC: newMidiCC,
                samplerDestinations: samplerDestinations
            )
            
            //let value = Double(midiCC.value) / 127
            //batteryCell.pitch = Pitch(value: value)
            
        }
        catch { print(error) }
        
    }
}
