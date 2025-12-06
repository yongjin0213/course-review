//
//  CourseDetailView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/4/25.
//

import SwiftUI

struct CourseReview: Identifiable {
    let id: Int
    let source: String
    let content: String
}

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
    @State private var reviews: [CourseReview] = []
    @State private var isLoadingReviews = false
    @State private var reviewLoadError: String? = nil
    
    private var course: Course? {
        courseStore.courses.first { $0.code == courseCode }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
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
        .onAppear {
            loadReviewsIfNeeded()
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
                if isLoadingReviews {
                    HStack {
                        ProgressView()
                        Text("Loading reviews...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                } else if let message = reviewLoadError {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                } else if reviews.isEmpty {
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
                        if let course = course {
                            RosterCardView(course: course)
                        } else {
                            Text("No roster data available.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
        }
    }
    
    
    private func loadReviewsIfNeeded() {
        guard let course = course,
              reviews.isEmpty,
              !isLoadingReviews else { return }
        
        isLoadingReviews = true
        reviewLoadError = nil
        
        Task { @MainActor in
            do {
                let apiReviews = try await NetworkManager.shared.fetchReviews(forCourseId: course.backendId)
                let mapped = apiReviews.map { api in
                    CourseReview(
                        id: api.id,
                        source: api.source,
                        content: api.content
                    )
                }
                reviews = mapped
                isLoadingReviews = false
            } catch {
                print("Failed to load reviews: \(error)")
                reviewLoadError = "Failed to load reviews."
                isLoadingReviews = false
            }
        }
    }
}

struct ReviewCardView: View {
    let review: CourseReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(review.source)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                    .font(.subheadline)
            }
            
            Text(review.content)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct RosterCardView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Course Roster")
                .font(.headline)
            
            Divider()
            
            infoRow(label: "Code", value: course.code)
            infoRow(label: "Title", value: course.title)
            infoRow(label: "Instructor", value: course.instructor.isEmpty ? "TBA" : course.instructor)
            infoRow(label: "Term", value: course.term.isEmpty ? "TBA" : course.term)
            infoRow(label: "Credits", value: course.credit == 0 ? "TBA" : "\(course.credit)")
            infoRow(label: "Department", value: course.department)
            
            if let summary = course.aiReview, !summary.isEmpty {
                Divider()
                Text("AI Summary")
                    .font(.subheadline.weight(.semibold))
                Text(summary)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}
