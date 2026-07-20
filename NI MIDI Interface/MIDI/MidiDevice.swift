//
//  MidiDevice.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import CoreMIDI

struct MidiDevice {
    let endpointRef: MIDIEndpointRef
    let uniqueID: MIDIUniqueID
    let name: String

    init(
        endpointRef: MIDIEndpointRef,
        uniqueID: MIDIUniqueID,
        name: String
    ){
        self.endpointRef = endpointRef
        self.uniqueID = uniqueID
        self.name = name
    }
}
extension MidiDevice: Equatable {
    static func == (lhs: MidiDevice, rhs: MidiDevice) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
}



struct MidiSource {
    let endpointRef: MIDIEndpointRef
    let uniqueID: MIDIUniqueID
    let name: String

    init(
        endpointRef: MIDIEndpointRef,
        uniqueID: MIDIUniqueID,
        name: String
    ){
        self.endpointRef = endpointRef
        self.uniqueID = uniqueID
        self.name = name
    }
}
extension MidiSource: Equatable {
    static func == (lhs: MidiSource, rhs: MidiSource) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
}
