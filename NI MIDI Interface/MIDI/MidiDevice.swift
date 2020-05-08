//
//  MidiDevice.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import MIKMIDI

struct MidiDevice {
    let mikEndpoint: MIKMIDIDestinationEndpoint
    
    init(
        virtualDestination: MIKMIDIDestinationEndpoint
    ){
        self.mikEndpoint = virtualDestination
    }
}
extension MidiDevice {
    var name: String {
        return mikEndpoint.name ?? "Unknown"
        //return endpointInfo?.displayName ?? "Unknown"
    }
    // CORE MIDI ENPOINT REF AND OBJECT REF ARE TYPEALIAS??
    /*
    var midiEndpointRef: MIDIEndpointRef {
        return mikEndpoint.objectRef
    }
 */
}
extension MidiDevice: Equatable {
    static func == (lhs: MidiDevice, rhs: MidiDevice) -> Bool {
        return
            lhs.mikEndpoint == rhs.mikEndpoint
    }
    
}



struct MidiSource {
    let mikEndpoint: MIKMIDISourceEndpoint
    
    init(
        mikMidiSourceEndpoint: MIKMIDISourceEndpoint
    ){
        self.mikEndpoint = mikMidiSourceEndpoint
    }
}
extension MidiSource {
    var name: String {
        return mikEndpoint.name ?? "Unknown"
        //return endpointInfo?.displayName ?? "Unknown"
    }
}
extension MidiSource: Equatable {
    static func == (lhs: MidiSource, rhs: MidiSource) -> Bool {
        return
            lhs.mikEndpoint == rhs.mikEndpoint
    }
    
}
