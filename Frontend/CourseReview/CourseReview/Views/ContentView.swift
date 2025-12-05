//
//  ContentView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 11/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                SearchView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            
            NavigationStack {
                SavedView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "bookmark.fill")
                Text("Saved")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profile")
            }
        }
        .accentColor(.red)
    }
}
