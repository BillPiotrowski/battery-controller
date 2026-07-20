//
//  MidiEvent.swift
//  Battery Controller
//
//  Created by Bill Piotrowski on 6/6/25.
//

//enum MidiEventType {
//    case NoteOn
//    case NoteOff
//    case ControlChange
//    case ProgramChange
//    case PitchBend
//    case System
//}

protocol MidiEvent {
    static var statusByte: UInt8 { get }
    var channel: UInt8 { get }
//    func getPacket() -> [UInt8]
    
    var midiBytes: [UInt8] { get }
}

struct MidiNoteOnEvent: MidiEvent {
    static var statusByte: UInt8 = 0x90
    let noteNumber: UInt8
    let velocity: UInt8
    let channel: UInt8
    var midiBytes: [UInt8] {
        [Self.statusByte | (channel & 0x0F), noteNumber, velocity]
    }
}

struct MidiNoteOffEvent: MidiEvent {
    static var statusByte: UInt8 = 0x80
    let noteNumber: UInt8
    let velocity: UInt8
    let channel: UInt8
    var midiBytes: [UInt8] {
        [Self.statusByte | (channel & 0x0F), noteNumber, velocity]
    }
}

struct MidiControlChangeEvent: MidiEvent {
    static var statusByte: UInt8 = 0xB0
    let controllerNumber: UInt8
    let value: UInt8
    let channel: UInt8
    var midiBytes: [UInt8] {
        [Self.statusByte | (channel & 0x0F), controllerNumber, value]
    }
}
