//
//  SampleCellData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/9/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct SampleCellData: ReadableData {
    
    var propertyData: SampleCellPropertyData
    var stateData: SampleCellStateData
    
    init(
        propertyData: SampleCellPropertyData,
        stateData: SampleCellStateData
    ){
        self.propertyData = propertyData
        self.stateData = stateData
    }
    
    init(){
        self.init(
            propertyData: SampleCellData.default.propertyData,
            stateData: SampleCellData.default.stateData
        )
    }
    
    init(dictionary: [String : Any]) throws {
        let propertyData = try SampleCellPropertyData(
            any: dictionary[Property.propertyData.rawValue]
        )
        let stateData = try SampleCellStateData(
            any: dictionary[Property.stateData.rawValue]
        )
        self.init(
            propertyData: propertyData,
            stateData: stateData
        )
    }
}

extension SampleCellData: WriteableData {
    var dictionary: [String : Any] {
        let dictionary = [
            Property.propertyData.rawValue: propertyData.dictionary,
            Property.stateData.rawValue: stateData.dictionary
        ]
        return dictionary
    }
    
    
}

// MARK: DEFINITIONS
extension SampleCellData {
    enum Property: String {
        case propertyData = "propertyData"
        case stateData = "stateData"
    }
}

extension SampleCellData {
    static let `default` = SampleCellData(
        propertyData: SampleCellPropertyData(),
        stateData: SampleCellStateData()
    )
}
