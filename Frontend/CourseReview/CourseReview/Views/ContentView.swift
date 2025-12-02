//
//  ContentView.swift
//
//
//  Created by Dheeraj Sai Thota on 11/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Search Screen")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            Text("Saved Screen")
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
            
            NavigationStack {
                ProfileView(profile: sampleProfile)
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profile")
            }
        }
        .accentColor(.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

