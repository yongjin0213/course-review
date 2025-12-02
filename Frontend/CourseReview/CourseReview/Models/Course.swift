//
//  Course.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/2/25.
//

import Foundation

struct Course: Identifiable {
    let id = UUID()
    let code: String
    let title: String
    let instructor: String
    let term: String
    let department: String
    let workloadScore: Double
    let ratingScore: Double
    let reviewCount: Int
    var isBookmarked: Bool
}

let sampleCourses: [Course] = [
    Course(
        code: "CS 2110",
        title: "Object-Oriented Programming and Data Structures",
        instructor: "Dr. Michael Clarkson",
        term: "SP2026",
        department: "Computer Science",
        workloadScore: 4.2,
        ratingScore: 4.5,
        reviewCount: 83,
        isBookmarked: true
    ),
    Course(
        code: "PSYCH 1101",
        title: "Introduction to Psychology",
        instructor: "Dr. Michael Clarkson",
        term: "SP2026",
        department: "Psychology",
        workloadScore: 3.1,
        ratingScore: 4.3,
        reviewCount: 61,
        isBookmarked: false
    ),
    Course(
        code: "INFO 1998",
        title: "Backend Development",
        instructor: "AppDev",
        term: "SP2026",
        department: "Information Science",
        workloadScore: 3.8,
        ratingScore: 4.7,
        reviewCount: 24,
        isBookmarked: false
    )
]
