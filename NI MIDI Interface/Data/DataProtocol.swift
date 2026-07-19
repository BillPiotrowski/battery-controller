//
//  DataProtocol.swift
//  Scorepio
//
//  Created by William Piotrowski on 11/2/19.
//  Copyright © 2019 William Piotrowski. All rights reserved.
//

import Foundation


protocol WPData {
    
}
extension WPData {
    var mirror: Mirror {
        return Mirror(reflecting: self)
    }
    var reflectedDictionary: [String: Any] {
        return Dictionary(
            uniqueKeysWithValues: mirror.children.enumerated().map{
                (String($0),$1)
            }
        )
    }
}

protocol EmbeddableData: _Data {
    var fullDictionary: [String: Any] { get }
}



protocol _Data: WriteableData, ReadableData {
    var dictionary: [String: Any] { get }
    init(dictionary: [String: Any]) throws
}


/*
extension _Data {
    // MARK: STRING GUARD
    static func typeGuardString(
        dictionary: [String: Any],
        key: String,
        previousKey: String? = nil
    ) throws -> String {
        guard
            let value = try Self.typeGuardExists(
                dictionary: dictionary,
                key: key,
                previousKey: previousKey
            ) as? String
            else {
                throw DataError.initIncorrectType(
                    variable: key,
                    dataType: Self.self,
                    varType: "string"
                )
        }
        return value
    }
    
    // MARK: DOUBLE GUARD
    static func typeGuardDouble(
        dictionary: [String: Any],
        key: String,
        previousKey: String? = nil
    ) throws -> Double {
        guard
            let value = try Self.typeGuardExists(
                dictionary: dictionary,
                key: key,
                previousKey: previousKey
            ) as? Double
            else {
                throw DataError.initIncorrectType(
                    variable: key,
                    dataType: Self.self,
                    varType: "double"
                )
        }
        return value
    }
    
    // MARK: STRING:ANY GUARD
    static func typeGuardStringAny(
        dictionary: [String: Any],
        key: String,
        previousKey: String? = nil
    ) throws -> [String: Any] {
        guard
            let value = try Self.typeGuardExists(
                dictionary: dictionary,
                key: key,
                previousKey: previousKey
            ) as? [String: Any]
            else {
                throw DataError.initIncorrectType(
                    variable: key,
                    dataType: Self.self,
                    varType: "string : any"
                )
        }
        return value
    }
    
    // MARK: EXIST GUARD
    /// Returns a value of Any if a value exists at the key. Can check for previous key as well.
    static func typeGuardExists(
        dictionary: [String: Any],
        key: String,
        previousKey: String? = nil
    ) throws -> Any {
        // SETS PREVIOUS VAL IF EXISTS
        let previousValue: Any?
        if let previousKey = previousKey {
            previousValue = dictionary[previousKey]
        } else {  previousValue = nil  }
        
        // RETURNS CURRENT VAL AND FALLS BACK TO PREVIOUS
        guard let value = dictionary[key] ?? previousValue
        else {
            throw DataError.initTypeMissingVariable(
                variable: key,
                type: Self.self
            )
        }
        return value
    }
    
}
*/

enum DataError: ScorepioError {
    
    
    case initMissingVariable(variable: String)
    case initTypeMissingVariable(variable: String, type: _Data.Type)
    case initIncorrectType(
        variable: String,
        dataType: _Data.Type,
        varType: String
    )
    case sequenceDataTypeDoesNotMatch
    
    var message: String {
        switch self {
        case .initTypeMissingVariable(let variable, let type):
            return "Could not initialize \(type) because \(variable) is not defined or correct type."
            
        case .initMissingVariable(let variable): return "Could not initialize because variable: \(variable) is not defined."
        case .sequenceDataTypeDoesNotMatch: return "Could not initialize sequenceData because type does not match."
        case .initIncorrectType(
            let variable,
            let dataType,
            let varType
        ):
            return "Could not initialize \(dataType) because variable \(variable) does not conform to type: \(varType)."
        }
    }
        
}

