//
//  NetworkManager.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/4/25.
//

import Foundation

struct APIReview: Decodable {
    let id: Int
    let source: String
    let content: String
    let course: Int
}

struct APICourse: Decodable {
    let id: Int
    let title: String
    let code: String
    let professor: String
    let term: String
    let credit: Int
    let aiReview: String?
    let reviews: [APIReview]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case code
        case professor
        case term
        case credit
        case aiReview = "ai_review"
        case reviews
    }
}

struct APICoursesResponse: Decodable {
    let courses: [APICourse]
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    
    func fetchCourses() async throws -> [APICourse] {
        let url = baseURL.appendingPathComponent("courses")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(APICoursesResponse.self, from: data)
        return decoded.courses
    }
}
