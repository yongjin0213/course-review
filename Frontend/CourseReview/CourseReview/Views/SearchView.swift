//
//  SearchView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/2/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var recentSearches: [String] = [
        "Object-Oriented Programming and Data Structures",
        "Introduction to Psychology"
    ]
    
    
    let courses: [Course] = sampleCourses
    
    private var filteredCourses: [Course] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return courses
        } else {
            let text = searchText.lowercased()
            return courses.filter { course in
                course.title.lowercased().contains(text) ||
                course.code.lowercased().contains(text) ||
                course.department.lowercased().contains(text)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        if isEditing && searchText.isEmpty {
                            recentSearchSection
                        } else {
                            courseListSection
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color(red: 0.78, green: 0.16, blue: 0.16))
                .frame(height: 120)
                .ignoresSafeArea(edges: .top)
            
            Text("Course Reviews")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.bottom, 65)
        }
    }
    
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search courses here...", text: $searchText, onEditingChanged: { editing in
                isEditing = editing
            })
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .onTapGesture {
            isEditing = true
        }
    }
    
    
    private var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Searches")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                ForEach(recentSearches, id: \.self) { text in
                    RecentSearchRowView(text: text) {
                        searchText = text
                        isEditing = true
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    
    private var courseListSection: some View {
        VStack(spacing: 12) {
            ForEach(filteredCourses) { course in
                CourseCardView(course: course)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }
}


struct CourseCardView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SmallTagView(text: course.code, background: Color(red: 0.88, green: 0.20, blue: 0.20), textColor: .white)
                SmallTagView(text: course.term, background: Color(.systemGray5), textColor: .primary)
                Spacer()
                Image(systemName: course.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(course.isBookmarked ? .black : .secondary)
            }
            
            Text(course.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(course.instructor)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 6) {
                SmallTagView(text: "Workload \(String(format: "%.1f", course.workloadScore))", background: Color(red: 0.93, green: 0.98, blue: 0.93), textColor: Color(red: 0.12, green: 0.46, blue: 0.18))
                SmallTagView(text: "\(course.reviewCount) Reviews", background: Color(red: 0.95, green: 0.96, blue: 0.99), textColor: Color(red: 0.16, green: 0.35, blue: 0.77))
                SmallTagView(text: "Rating \(String(format: "%.1f", course.ratingScore))", background: Color(red: 0.99, green: 0.93, blue: 0.93), textColor: Color(red: 0.75, green: 0.12, blue: 0.07))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SmallTagView: View {
    let text: String
    let background: Color
    let textColor: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .foregroundColor(textColor)
            .cornerRadius(10)
    }
}

struct RecentSearchRowView: View {
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .foregroundColor(.primary)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
