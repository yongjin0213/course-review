//
//  Item.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 11/30/25.
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
