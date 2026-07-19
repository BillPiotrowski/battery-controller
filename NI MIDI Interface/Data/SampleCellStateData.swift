//
//  SampleCellStateData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/8/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellStateData: ReadableData {
    var mute: Bool
    var solo: Bool
    var lock: Bool
    
    init(
        mute: Bool,
        solo: Bool,
        lock: Bool
    ){
        self.mute = mute
        self.solo = solo
        self.lock = lock
    }
    
    init(){
        self.init(
            mute: SampleCellStateData.default.mute,
            solo: SampleCellStateData.default.solo,
            lock: SampleCellStateData.default.lock
        )
    }
    
    init(dictionary: [String : Any]) throws {
        let mute = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.mute.rawValue
        )
        let solo = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.solo.rawValue
        )
        let lock = try Self.asBoolIn(
            dictionary: dictionary,
            key: Property.lock.rawValue
        )
        self.init(
            mute: mute,
            solo: solo,
            lock: lock
        )
    }
}

// MARK: WRITEABLE
extension SampleCellStateData: WriteableData {
    var dictionary: [String : Any] {
        let dictionary = [
            Property.mute.rawValue: mute,
            Property.solo.rawValue: solo,
            Property.lock.rawValue: lock
        ]
        return dictionary
    }
    
    
}

// MARK: DEFAULT
extension SampleCellStateData {
    static let `default`: SampleCellStateData = SampleCellStateData(
        mute: false,
        solo: false,
        lock: false
    )
}

// MARK: DEFINITIONS
extension SampleCellStateData {
    enum Property: String {
        case mute = "mute"
        case solo = "solo"
        case lock = "lock"
    }
}

extension SampleCellStateData {
    func getAllMidiCCs(channel: MidiChannel) -> [MidiCCValueMap] {
        return [
            .mute(value: mute),
            .solo(value: solo),
            .isEditingLocked(value: lock)
        ]
    }
}
