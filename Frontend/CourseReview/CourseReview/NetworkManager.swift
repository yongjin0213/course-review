//
//  NetworkManager.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/4/25.
//

import Foundation

struct APICourseSummary: Decodable {
    let id: Int
    let title: String
    let code: String
    let aiReview: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case code
        case aiReview = "ai_review"
    }
}

struct APICoursesResponse: Decodable {
    let courses: [APICourseSummary]
}

struct APIReview: Decodable {
    let id: Int
    let source: String
    let content: String
    let rating: Int
    let courseId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case content
        case rating
        case courseId = "course_id"
    }
}

struct APIReviewsResponse: Decodable {
    let reviews: [APIReview]
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    private let baseURL = URL(string: "http://127.0.0.1:8000/api")!
    
    func fetchCourses() async throws -> [APICourseSummary] {
        let url = baseURL.appendingPathComponent("courses")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(APICoursesResponse.self, from: data)
        return decoded.courses
    }
    
    func fetchReviews(forCourseId courseId: Int) async throws -> [APIReview] {
        let url = baseURL
            .appendingPathComponent("reviews")
            .appendingPathComponent(String(courseId))
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(APIReviewsResponse.self, from: data)
        return decoded.reviews
    }
}
