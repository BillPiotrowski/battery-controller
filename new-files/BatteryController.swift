//
//  BatterController.swift
//  Battery Controller
//
//  Created by Bill Piotrowski on 6/6/25.
//

import Foundation

class BatteryController: ObservableObject {
    static let startingNoteNumber: UInt8 = 48
    static let numberOfNotes: Int = 16
    static let endingNoteNumber = startingNoteNumber + UInt8(numberOfNotes)
    private let pitchMapping: CCMapping
    private let ccMappings: [CCMapping]
    
    
    @Published var cells: [Cell]
//    @Published var currentChannelId: UInt8 = 1
    public private(set) var currentChannelIndex: Int = 0
    
    init(){
        // Probably should filter list to remove duplicate inputs / outputs?
        let mappings: [CCMapping] = [
            CCMapping(property: "Pitch", inputNumber: 14, defaultValue: 48),
            CCMapping(property: "Start Coarse", inputNumber: 15, defaultValue: 64, outputNumber: 21),
            CCMapping(property: "Start Fine", inputNumber: 16, defaultValue: 64, outputNumber: 21),
            
            CCMapping(property: "Attack", inputNumber: 17, defaultValue: 64, outputNumber: 25),
            CCMapping(property: "Decay", inputNumber: 18, defaultValue: 64, outputNumber: 26),
            CCMapping(property: "Sustain", inputNumber: 19, defaultValue: 64, outputNumber: 27),
            CCMapping(property: "Release", inputNumber: 20, defaultValue: 64, outputNumber: 30),
            CCMapping(property: "Volume", inputNumber: 21, defaultValue: 100, outputNumber: 59),
            
            CCMapping(property: "Speed", inputNumber: 60, defaultValue: 64, outputNumber: 28),
            
            CCMapping(property: "Cutoff HP", inputNumber: 61, defaultValue: 64, outputNumber: 40),
            CCMapping(property: "Cutoff LP", inputNumber: 62, defaultValue: 64, outputNumber: 41),
            
            CCMapping(property: "Transient Master Toggle", inputNumber: 66, defaultValue: 64, outputNumber: 45),
            CCMapping(property: "Transient Master Attack", inputNumber: 63, defaultValue: 64, outputNumber: 42),
            CCMapping(property: "Transient Master Sustain", inputNumber: 64, defaultValue: 64, outputNumber: 43),
            
            CCMapping(property: "Tune Coarse", inputNumber: 65, defaultValue: 64, outputNumber: 44),
            CCMapping(property: "Tune Fine", inputNumber: 67, defaultValue: 64, outputNumber: 46),
            
            CCMapping(property: "Lofi Toggle", inputNumber: 50, defaultValue: 64, outputNumber: 71),
            CCMapping(property: "Bits", inputNumber: 40, defaultValue: 64, outputNumber: 51),
            CCMapping(property: "Sampling Rate", inputNumber: 41, defaultValue: 64, outputNumber: 52),
            CCMapping(property: "Noise", inputNumber: 42, defaultValue: 64, outputNumber: 53),
            CCMapping(property: "Noise Color", inputNumber: 43, defaultValue: 64, outputNumber: 54),
            CCMapping(property: "Output", inputNumber: 44, defaultValue: 64, outputNumber: 55),
            
            CCMapping(property: "Send Reverb", inputNumber: 45, defaultValue: 64, outputNumber: 56),
            CCMapping(property: "Delay Send", inputNumber: 46, defaultValue: 64, outputNumber: 57),
            
            CCMapping(property: "Velocity Intensity", inputNumber: 47, defaultValue: 64, outputNumber: 58),
            
            CCMapping(property: "Pan", inputNumber: 52, defaultValue: 64, outputNumber: 60),
            CCMapping(property: "Hold", inputNumber: 51, defaultValue: 64, outputNumber: 29),
            
        ]
        let pitchMapping = mappings.first { ccMapping in
            ccMapping.property == "Pitch"
        } ?? CCMapping(property: "Pitch", inputNumber: 14, defaultValue: 48, outputNumber: nil)
        let ccProperties: [String: UInt8] = Dictionary(uniqueKeysWithValues: mappings.map { ($0.property, $0.defaultValue) })
        let cells = (0..<Self.numberOfNotes).map {
            Cell(id: $0, channel: UInt8($0), pitch: pitchMapping.defaultValue, ccProperties: ccProperties)
        }
        
        self.pitchMapping = pitchMapping
        self.ccMappings = mappings
        self.cells = cells
    }
    
    func processMidiEvent(_ event: MidiEvent) -> MidiEvent? {
        
        switch event {
        case let noteOn as MidiNoteOnEvent:
            if(
                noteOn.noteNumber >= Self.startingNoteNumber &&
                noteOn.noteNumber < Self.endingNoteNumber
            ){
                let channelIndex = Int(noteOn.noteNumber - Self.startingNoteNumber)
                print(channelIndex)
                DispatchQueue.main.async {
                    self.currentChannelIndex = channelIndex
                }
                if !self.cells.indices.contains(channelIndex) {
                    print("Index \(channelIndex) does not exist in the array")
                    return nil
                }
                let cell = self.cells[channelIndex]
                cell.playingPitch = cell.pitch
                return MidiNoteOnEvent(
                    noteNumber: cell.pitch,
                    velocity: noteOn.velocity,
                    channel: cell.channel
                )
            }
        case let noteOff as MidiNoteOffEvent:
            if(
                noteOff.noteNumber >= Self.startingNoteNumber &&
                noteOff.noteNumber < Self.endingNoteNumber
            ){
                let channelIndex = Int(noteOff.noteNumber - Self.startingNoteNumber)
                DispatchQueue.main.async {
                    self.currentChannelIndex = channelIndex
                }
                if !self.cells.indices.contains(channelIndex) {
                    print("Index \(channelIndex) does not exist in the array")
                    return nil
                }
                let cell = self.cells[channelIndex]
                return MidiNoteOffEvent(noteNumber: cell.playingPitch ?? cell.pitch, velocity: cell.channel, channel: cell.channel)
            }
        case let cc as MidiControlChangeEvent:
            if(cc.controllerNumber == self.pitchMapping.inputNumber){
                if !self.cells.indices.contains(self.currentChannelIndex) {
                    return nil
                }
                let cell = self.cells[self.currentChannelIndex]
                cell.pitch = cc.value
                return nil
            }
            if let midiMapping = self.ccMappings.first(where: { map in
                map.inputNumber == cc.controllerNumber
            }){
                if !self.cells.indices.contains(self.currentChannelIndex) {
                    return nil
                }
                let cell = self.cells[self.currentChannelIndex]
                cell.ccProperties[midiMapping.property] = cc.value
                return MidiControlChangeEvent(
                    controllerNumber: midiMapping.outputNumber,
                    value: cc.value,
                    channel: cell.channel
                )
            }
            return nil

        default:
            print("Unknown MIDI event")
        }
        return nil
    }
    
    func getReturnPackets(events: [MidiEvent], startingChannelIndex: Int) -> [MidiEvent] {
        let lastNoteOn = events.last { event in
            switch event {
            case let noteOn as MidiNoteOnEvent:
                return noteOn.channel != startingChannelIndex
            default:
                break
            }
            return false
        }
        if let lastNoteOn = lastNoteOn {
            let cell = self.cells[Int(lastNoteOn.channel)]
            var ccUpdates: [MidiEvent] = cell.ccProperties.compactMap { key, val in
                guard let mapping = self.ccMappings.first(where: { m in
                    m.property == key
                }) else {
                    return nil
                }
                return MidiControlChangeEvent(controllerNumber: mapping.inputNumber, value: val, channel: 0)
            }
            ccUpdates.append(MidiControlChangeEvent(controllerNumber: self.pitchMapping.inputNumber, value: cell.pitch, channel: 0))
            return ccUpdates
        }
        return []
    }
    
    
}
