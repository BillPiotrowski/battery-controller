//
//  ReadableData.swift
//  Scorepio
//
//  Created by William Piotrowski on 3/2/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

protocol ReadableData: Typeguard {
    init(dictionary: [String: Any]) throws
}
extension ReadableData {
    init(any: Any?) throws {
        let dictionary = try Self.asStringAny(value: any, key: "dictionary", initializer: String(describing: Self.self))
        try self.init(dictionary: dictionary)
    }
}

