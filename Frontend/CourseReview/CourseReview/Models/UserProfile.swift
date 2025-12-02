//
//  UserProfile.swift
//  
//
//  Created by Dheeraj Sai Thota on 11/30/25.
//

import Foundation

struct UserProfile {
    let name: String
    let classYear: String
    let major: String
    let minor: String?
    let areasOfInterest: [String]
    let learningPreferences: [String]
}

let sampleProfile = UserProfile(
    name: "Ezra Cornell",
    classYear: "Junior ’27",
    major: "Computer Science",
    minor: "Minor in Mathematics",
    areasOfInterest: [
        "Artificial Intelligence",
        "Data Science",
        "Backend Development",
        "Linear Algebra"
    ],
    learningPreferences: [
        "Good lecturer",
        "Project-Based",
        "Not reading heavy"
    ]
)
