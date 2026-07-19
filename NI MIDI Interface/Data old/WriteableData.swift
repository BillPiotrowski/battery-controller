//
//  WriteableData.swift
//  Scorepio
//
//  Created by William Piotrowski on 3/2/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Foundation

protocol WriteableData {
    var dictionary: [String: Any] { get }
}
extension WriteableData {
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
}
