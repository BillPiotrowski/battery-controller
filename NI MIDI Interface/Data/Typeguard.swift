//
//  Typeguard.swift
//  Scorepio
//
//  Created by William Piotrowski on 3/7/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

protocol Typeguard: WPData {
    
}



// MARK: AS STRING:ANY
extension Typeguard {
    /// Evaluates and returns value as [String: Any], otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as [String: Any]
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asStringAny(
        value: Any?,
        key: String?,
        initializer: String? = nil
    ) throws -> [String:Any] {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let stringAny = value as? [String: Any] else {
            throw TypeguardError.valueIsNot(.stringAny, key: key, initializer: initializer)
        }
        return stringAny
    }
    
    /// Evaluates and returns value as [String:Any] from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as [String:Any] at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asStringAnyIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> [String:Any] {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asStringAny(value: value, key: key, initializer: initializer)
    }
}

// MARK: AS DOUBLE
extension Typeguard {
    /// Evaluates and returns value as Double, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Double.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asDouble(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> Double {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let double = value as? Double else {
            throw TypeguardError.valueIsNot(.double, key: key, initializer: initializer)
        }
        return double
    }
    
    /// Evaluates and returns value as Double from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as Double at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asDoubleIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> Double {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asDouble(value: value, key: key, initializer: initializer)
    }
}






// MARK: AS NSDecimalNumber
extension Typeguard {
    /// Evaluates and returns value as NSDecimalNumber, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as NSDecimalNumber.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asNSDecimalNumber(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> NSDecimalNumber {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        do {
            let double = try Self.asDouble(
                value: value,
                key: key,
                initializer: initializer
            )
            return NSDecimalNumber(value: double)
        } catch {
            throw TypeguardError.valueIsNot(.nsDecimalNumber, key: key, initializer: initializer)
        }
    }
    
    /// Evaluates and returns value as NSDecimalNumber from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as NSDecimalNumber at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asNSDecimalNumberIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> NSDecimalNumber {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asNSDecimalNumber(value: value, key: key, initializer: initializer)
    }
}



// MARK: AS STRING
extension Typeguard {
    /// Evaluates and returns value as String, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as String.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asString(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> String {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let string = value as? String else {
            throw TypeguardError.valueIsNot(.double, key: key, initializer: initializer)
        }
        return string
    }
    
    /// Evaluates and returns value as String from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as String at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asStringIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> String {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asString(value: value, key: key, initializer: initializer)
    }
}











// MARK: AS BOOL
extension Typeguard {
    /// Evaluates and returns value as Bool, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Bool.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asBool(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> Bool {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let bool = value as? Bool else {
            throw TypeguardError.valueIsNot(.bool, key: key, initializer: initializer)
        }
        return bool
    }
    
    /// Evaluates and returns value as Bool from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as Bool at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asBoolIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> Bool {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asBool(value: value, key: key, initializer: initializer)
    }
}






// MARK: AS INT
extension Typeguard {
    /// Evaluates and returns value as Int, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Int.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asInt(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> Int {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let int = value as? Int else {
            throw TypeguardError.valueIsNot(.bool, key: key, initializer: initializer)
        }
        return int
    }
    
    /// Evaluates and returns value as Int from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as Int at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asIntIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> Int {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asInt(value: value, key: key, initializer: initializer)
    }
}








// MARK: AS Float
extension Typeguard {
    /// Evaluates and returns value as Float, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Float.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asFloat(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> Float {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let float = value as? Float else {
            throw TypeguardError.valueIsNot(.float, key: key, initializer: initializer)
        }
        return float
    }
    
    /// Evaluates and returns value as Float from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as Float at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asFloatIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> Float {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asFloat(value: value, key: key, initializer: initializer)
    }
}











// MARK: AS STRING ARRAY
extension Typeguard {
    /// Evaluates and returns value as [String], otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as [String].
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asStringArray(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> [String] {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let stringArray = value as? [String] else {
            throw TypeguardError.valueIsNot(.stringArray, key: key, initializer: initializer)
        }
        return stringArray
    }
    
    /// Evaluates and returns value as [String] from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as [String] at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asStringArrayIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> [String] {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asStringArray(value: value, key: key, initializer: initializer)
    }
}



// MARK: AS ARRAY
extension Typeguard {
    /// Evaluates and returns value as [Any], otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as [Any].
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asArray(
        value: Any?,
        key: String,
        initializer: String? = nil
    ) throws -> [Any] {
        let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = initializer ?? String(describing: Self.self)
        guard let array = value as? [Any] else {
            throw TypeguardError.valueIsNot(.array, key: key, initializer: initializer)
        }
        return array
    }
    
    /// Evaluates and returns value as [Any] from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as [Any] at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asArrayIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> [Any] {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asArray(value: value, key: key, initializer: initializer)
    }
}

// MARK: AS DEFINED
extension Typeguard {
    /// Evaluates and returns value as Defined (non nil), otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Defined (non nil).
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asDefined(
        value: Any?,
        key: String?,
        initializer: String? = nil
    ) throws -> Any {
        let initializer = initializer ?? String(describing: Self.self)
        guard let value = value else {
            throw TypeguardError.valueIsNot(.defined, key: key, initializer: initializer)
        }
        return value
    }
    
    /// Evaluates and returns value as Defined (non nil) from dictionary at the given key, otherwise throws error.
    /// - Parameters:
    ///   - dictionary: The [String:Any] to pull the value to be evaluated as Defined (non nil) at given key.
    ///   - key: The key used to lookup the value to be evaluated in dictionary. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging. Default will use the name of the struct making the call.
    ///   - previousKey: Optional. A string that has been used to define this value in the past. Used to help transition when data names are changed.
    static func asDefinedIn(
        dictionary: [String: Any],
        key: String,
        initializer: String? = nil,
        previousKey: String? = nil
    ) throws -> Any {
        let value = dictionary[key] ?? Self.previousValueFrom(dictionary: dictionary, previousKey: previousKey)
        return try Self.asDefined(value: value, key: key, initializer: initializer)
    }
    
    
    
}




// MARK: AS SELF
extension Typeguard {
    /// Evaluates and returns value as Self, otherwise throws error.
    /// - Parameters:
    ///   - value: input to be evaluated as Self.
    ///   - key: Optional. The key associated with intended value. Used for accurate error messaging.
    ///   - initializer: Optional. The initializer that is calling the typeguard. Used for accurate error messaging.
    static func asSelf(
        value: Any
    ) throws -> Self {
        //let value = try asDefined(value: value, key: key, initializer: initializer)
        let initializer = String(describing: Self.self)
        guard let selfValue = value as? Self else {
            throw TypeguardError.valueIsNot(.bool, key: initializer, initializer: initializer)
        }
        return selfValue
    }
}








/*
extension Typeguard {
    static func errorMessage(
        type: String,
        initializer: String,
        key: String?
    ) -> String{
        return "Could not intialize \(initializer) because the value of \(key ?? "unknown") is not \(type)."
    }
}
 */

// MARK: HELPER METHODS
extension Typeguard {
    static func previousValueFrom(
        dictionary: [String: Any],
        previousKey: String?
    ) -> Any? {
        guard let previousKey = previousKey else { return nil }
        return dictionary[previousKey]
    }
}

extension Typeguard {
    static var initName: String {
        return String(describing: Self.self)
    }
}




enum TypeguardError: ScorepioError {
    case valueIsNot(
        _ type: TypeString,
        key: String?,
        initializer: String,
        typeName: String? = nil
    )
    
    var message: String {
        switch self {
        case
        .valueIsNot(let type, let key, let initializer, let typeName):
            let typeString = typeName ?? type.rawValue
            return "Could not intialize \(initializer) because the value of \(key ?? "unknown") is not \(typeString)."
        }
    }
    enum TypeString: String {
        case defined = "defined"
        case stringAny = "[String: Any]"
        case string = "a String"
        case double = "a Double"
        case float = "a Float"
        case bool = "a Bool"
        case stringArray = "a String Array [String]"
        case array = "an Array [Any]"
        case timestamp = "Timestamp"
        case nsDecimalNumber = "NSDecimalNumber"
        case custom = "an unknown type"
    }
    
}
