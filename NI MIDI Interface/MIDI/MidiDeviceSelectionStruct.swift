//
//  MidiDeviceSelectionStruct.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/6/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct MidiDeviceSelectionStruct {
    let options: [String]
    let selectedIndex: Int
}

class MidiOutputInfo {
    // MAKE WEAK?
    let midiDestination: MidiDevice
    let active: Bool
    
    init(
        midiDestination: MidiDevice,
        active: Bool
    ){
        self.midiDestination = midiDestination
        self.active = active
    }
}
extension MidiOutputInfo {
    var uid: Int32 {
        return midiDestination.mikEndpoint.uniqueID
    }
    var name: String {
        return midiDestination.name
    }
}
