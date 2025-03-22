//
//  Item.swift
//  Potluck
//
//  Created by ET Loaner on 3/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
