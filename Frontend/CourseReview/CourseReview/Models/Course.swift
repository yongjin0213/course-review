//
//  Course.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/2/25.
//


import Foundation

struct Course: Identifiable {
    let id = UUID()
    let backendId: Int
    let code: String
    let title: String
    let instructor: String
    let term: String
    let department: String
    let credit: Int
    let workloadScore: Double
    let ratingScore: Double
    let reviewCount: Int
    let aiReview: String?
    var isBookmarked: Bool
}

let sampleCourses: [Course] = [
    Course(
        backendId: -1,
        code: "CS 2110",
        title: "Object-Oriented Programming and Data Structures",
        instructor: "Dr. Michael Clarkson",
        term: "SP2026",
        department: "Computer Science",
        credit: 4,
        workloadScore: 4.2,
        ratingScore: 4.5,
        reviewCount: 83,
        aiReview: nil,
        isBookmarked: true
    ),
    Course(
        backendId: -2,
        code: "PSYCH 1101",
        title: "Introduction to Psychology",
        instructor: "Dr. Michael Clarkson",
        term: "SP2026",
        department: "Psychology",
        credit: 4,
        workloadScore: 3.1,
        ratingScore: 4.3,
        reviewCount: 61,
        aiReview: nil,
        isBookmarked: false
    ),
    Course(
        backendId: -3,
        code: "INFO 1998",
        title: "Backend Development",
        instructor: "AppDev",
        term: "SP2026",
        department: "Information Science",
        credit: 4,
        workloadScore: 3.8,
        ratingScore: 4.7,
        reviewCount: 24,
        aiReview: nil,
        isBookmarked: false
    )
]

@MainActor
final class CourseStore: ObservableObject {
    @Published var courses: [Course]
    
    private let bookmarkDefaultsKey = "bookmarkedCourseCodes"
    
    init(courses: [Course] = sampleCourses) {
        let storedCodes = UserDefaults.standard.stringArray(forKey: bookmarkDefaultsKey) ?? []
        
        self.courses = courses.map { course in
            var mutable = course
            mutable.isBookmarked = storedCodes.contains(course.code)
            return mutable
        }
    }
    
    func toggleBookmark(for course: Course) {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else {
            return
        }
        courses[index].isBookmarked.toggle()
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        let codes = courses
            .filter { $0.isBookmarked }
            .map { $0.code }
        UserDefaults.standard.set(codes, forKey: bookmarkDefaultsKey)
    }
    
    func reloadFromServer() async {
        do {
            let apiCourses = try await NetworkManager.shared.fetchCourses()
            let storedCodes = UserDefaults.standard.stringArray(forKey: bookmarkDefaultsKey) ?? []
            func department(from code: String) -> String {
                let prefix = code.split(separator: " ").first.map(String.init) ?? ""
                return prefix.isEmpty ? "Unknown" : prefix
            }
            
            let remoteCourses: [Course] = apiCourses.map { api in
                let sample = sampleCourses.first { $0.code == api.code }
                
                return Course(
                    backendId: api.id,
                    code: api.code,
                    title: api.title,
                    instructor: sample?.instructor ?? "",
                    term: sample?.term ?? "",
                    department: sample?.department ?? department(from: api.code),
                    credit: sample?.credit ?? 0,
                    workloadScore: sample?.workloadScore ?? 0.0,
                    ratingScore: sample?.ratingScore ?? 0.0,
                    reviewCount: sample?.reviewCount ?? 0,
                    aiReview: api.aiReview,
                    isBookmarked: storedCodes.contains(api.code)
                )
            }
            let existingCodes = Set(remoteCourses.map { $0.code })
            let extraSamples = sampleCourses.filter { !existingCodes.contains($0.code) }
            courses = extraSamples + remoteCourses
        } catch {
            print("Failed to fetch courses: \(error)")
        }
    }
}
