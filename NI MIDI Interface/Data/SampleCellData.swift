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
    var ampEnvelopeData: SampleCellAmpEnvelopeData
    var stateData: SampleCellStateData
    var loFiData: SampleCellLoFiData
    var sampleData: SampleCellSampleData
    
    init(
        propertyData: SampleCellPropertyData,
        ampEnvelopeData: SampleCellAmpEnvelopeData,
        loFiData: SampleCellLoFiData,
        sampleData: SampleCellSampleData,
        stateData: SampleCellStateData
        
    ){
        self.propertyData = propertyData
        self.stateData = stateData
        self.loFiData = loFiData
        self.sampleData = sampleData
        self.ampEnvelopeData = ampEnvelopeData
    }
    
    init(dictionary: [String : Any]) throws {
        let propertyData = try SampleCellPropertyData(
            any: dictionary[Property.propertyData.rawValue]
        )
        let stateData = try SampleCellStateData(
            any: dictionary[Property.stateData.rawValue]
        )
        let ampEnvelopeData = try SampleCellAmpEnvelopeData(
            any: dictionary[Property.ampEnvelopeData.rawValue]
        )
        let loFiData = try SampleCellLoFiData(
            any: dictionary[Property.loFiData.rawValue]
        )
        let sampleData = try SampleCellSampleData(
            any: dictionary[Property.sampleData.rawValue]
        )
        self.init(
            propertyData: propertyData,
            ampEnvelopeData: ampEnvelopeData,
            loFiData: loFiData,
            sampleData: sampleData,
            stateData: stateData
        )
    }
}

extension SampleCellData: WriteableData {
    var dictionary: [String : Any] {
        let dictionary = [
            Property.propertyData.rawValue: propertyData.dictionary,
            Property.stateData.rawValue: stateData.dictionary,
            Property.ampEnvelopeData.rawValue: ampEnvelopeData.dictionary,
            Property.loFiData.rawValue: loFiData.dictionary,
            Property.sampleData.rawValue: sampleData.dictionary
        ]
        return dictionary
    }
    
    
}

// MARK: DEFINITIONS
extension SampleCellData {
    enum Property: String {
        case propertyData = "propertyData"
        case stateData = "stateData"
        case ampEnvelopeData = "ampEnvelopeData"
        case loFiData = "loFiData"
        case sampleData = "sampleData"
    }
}

extension SampleCellData {
    static let `default` = SampleCellData(
        propertyData: SampleCellPropertyData.default,
        ampEnvelopeData: SampleCellAmpEnvelopeData.default,
        loFiData: SampleCellLoFiData.default,
        sampleData: SampleCellSampleData.default,
        stateData: SampleCellStateData()
    )
}
