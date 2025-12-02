//
//  SavedView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/2/25.
//

import SwiftUI

struct SavedView: View {
    let courses: [Course] = sampleCourses
    
    private var savedCourses: [Course] {
        courses.filter { $0.isBookmarked }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if savedCourses.isEmpty {
                    VStack {
                        Spacer()
                        Text("No saved courses yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(savedCourses) { course in
                                CourseCardView(course: course)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
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
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                
                Text("Saved")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 65)
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView()
    }
}
