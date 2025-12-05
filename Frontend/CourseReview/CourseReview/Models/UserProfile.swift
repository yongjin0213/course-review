//
//  UserProfile.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 11/30/25.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var classYear: String
    var major: String
    var minor: String?
    var areasOfInterest: [String]
    var learningPreferences: [String]
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
