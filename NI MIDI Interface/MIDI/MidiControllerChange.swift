//
//  MidiControllerChange.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/2/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

struct MidiControllerChange {
    let ccNumber: MidiControlChangeNumber
    let value: MidiControlChangeValue
    let channel: MidiChannel
    //let destinationDevices: [MidiDevice]?
    
    init(
        ccNumber: MidiControlChangeNumber,
        value: MidiControlChangeValue,
        channel: MidiChannel//,
        //destinationDevices: [MidiDevice]? = nil
    ){
        self.ccNumber = ccNumber
        self.value = value
        self.channel = channel
        //self.destinationDevices = destinationDevices
    }
}
extension MidiControllerChange {
    var ratio: Double {
        return Double(value) / Double(MidiControllerChange.totalUnits)
    }
    static let totalUnits: Int = 127
    var bool: Bool {
        guard value == MidiControllerChange.totalUnits
            else { return false }
        return true
    }
}
