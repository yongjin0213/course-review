//
//  CourseDetailView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/4/25.
//

import SwiftUI

struct CourseReview: Identifiable {
    let id = UUID()
    let professor: String
    let grade: String
    let major: String
    let rating: Int
    let difficulty: Int
    let workload: Int
    let comment: String
    let dateString: String
}

let sampleReviewsByCourse: [String: [CourseReview]] = [
    "CS 2110": [
        CourseReview(
            professor: "Anushman Mohan",
            grade: "A-",
            major: "Computer Science",
            rating: 3,
            difficulty: 3,
            workload: 5,
            comment: "Weekly projects were very time consuming.",
            dateString: "5/19/2025"
        )
    ]
]

enum ReviewTab: String, CaseIterable {
    case all = "All"
    case cuReviews = "CU Reviews"
    case roster = "Class Roster"
}

struct CourseDetailView: View {
    @EnvironmentObject var courseStore: CourseStore
    @Environment(\.dismiss) private var dismiss
    
    let courseCode: String
    @State private var selectedTab: ReviewTab = .all
    
    private var course: Course? {
        courseStore.courses.first { $0.code == courseCode }
    }
    
    private var reviews: [CourseReview] {
        sampleReviewsByCourse[courseCode] ?? []
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                if let course = course {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            courseHeaderCard(course: course)
                            
                            tabBar
                            
                            reviewSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("Course not found.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var topBar: some View {
        ZStack {
            Color(.systemGray5)
                .frame(height: 44)
                .ignoresSafeArea(edges: .top)
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func courseHeaderCard(course: Course) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SmallTagView(
                    text: course.code,
                    background: .black,
                    textColor: .white
                )
                SmallTagView(
                    text: course.term,
                    background: Color(.systemGray5),
                    textColor: .primary
                )
                Spacer()
                Button {
                    courseStore.toggleBookmark(for: course)
                } label: {
                    Image(systemName: course.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.leading)
                
                Text(course.instructor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.top, 16)
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ReviewTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == tab ? .primary : .clear)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch selectedTab {
            case .all, .cuReviews:
                if reviews.isEmpty {
                    Text("No reviews yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                } else {
                    ForEach(reviews) { review in
                        ReviewCardView(review: review)
                    }
                }
            case .roster:
                Text("Class roster data coming soon.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
    }
}

struct ReviewCardView: View {
    let review: CourseReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    labelValueRow(label: "Professor", value: review.professor, bold: true)
                    labelValueRow(label: "Grade", value: review.grade)
                    labelValueRow(label: "Major", value: review.major, bold: true)
                }
                
                Spacer(minLength: 0)
                
                VStack(alignment: .leading, spacing: 4) {
                    labelValueRow(label: "Rating", value: "\(review.rating)")
                    labelValueRow(label: "Difficulty", value: "\(review.difficulty)")
                    labelValueRow(label: "Workload", value: "\(review.workload)")
                }
            }
            
            Text(review.comment)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(review.dateString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    private func labelValueRow(label: String, value: String, bold: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(bold ? .subheadline.weight(.semibold) : .subheadline)
        }
    }
}
