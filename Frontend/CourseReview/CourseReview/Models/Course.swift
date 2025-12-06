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
            async let coursesTask = NetworkManager.shared.fetchCourses()
            async let reviewsTask = NetworkManager.shared.fetchAllReviews()
            
            let apiCourses = try await coursesTask
            let allReviews = try await reviewsTask
            
            let storedCodes = UserDefaults.standard.stringArray(forKey: bookmarkDefaultsKey) ?? []
            
            let reviewCounts: [Int: Int] = Dictionary(
                grouping: allReviews,
                by: { $0.courseId }
            ).mapValues { $0.count }
            
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
                    reviewCount: reviewCounts[api.id] ?? 0,
                    aiReview: api.aiReview,
                    isBookmarked: storedCodes.contains(api.code)
                )
            }
            
            let existingCodes = Set(remoteCourses.map { $0.code })
            let extraSamples = sampleCourses.filter { !existingCodes.contains($0.code) }
            courses = remoteCourses
        } catch {
            print("Failed to fetch courses or reviews: \(error)")
        }
    }
}
