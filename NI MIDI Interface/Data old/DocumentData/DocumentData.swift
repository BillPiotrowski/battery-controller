//
//  DocumentData.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

struct DocumentData: ReadableData {
    let sampleCellsData: [SampleCellData]
    
    init(sampleCellsData: [SampleCellData]){
        self.sampleCellsData = sampleCellsData
    }
    init(){
        var sampleCellsData = [SampleCellData]()
        for n in 0...15 {
            sampleCellsData.append(SampleCellData())
        }
        self.init(sampleCellsData: sampleCellsData)
    }
    
    init(dictionary: [String : Any]) throws {
        let sampleCellsDataArray = try Self.asArrayIn(
            dictionary: dictionary,
            key: Property.sampleCellsData.rawValue
        )
        var sampleCellsData = [SampleCellData]()
        for sampleCellDataAny in sampleCellsDataArray {
            let sampleCellData = try SampleCellData(any: sampleCellDataAny)
            sampleCellsData.append(sampleCellData)
        }
        self.init(sampleCellsData: sampleCellsData)
    }
    
    
}

extension DocumentData: WriteableData {
    var dictionary: [String : Any] {
        var sampleCellsDictionaryArray = [[String: Any]]()
        for sampleCellData in sampleCellsData {
            sampleCellsDictionaryArray.append(sampleCellData.dictionary)
        }
        return [
            Property.sampleCellsData.rawValue: sampleCellsDictionaryArray
        ]
    }
}

extension DocumentData {
    enum Property: String {
        case sampleCellsData = "sampleCellsData"
    }
}
