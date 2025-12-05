//
//  CourseReviewApp.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 11/30/25.
//

import SwiftUI
import SwiftData

@main
struct CourseReviewApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var courseStore = CourseStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(courseStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
