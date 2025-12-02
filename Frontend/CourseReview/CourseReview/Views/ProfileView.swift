//
//  ProfileView.swift
//  
//
//  Created by Dheeraj Sai Thota on 12/1/25.
//

import SwiftUI

struct ProfileView: View {
    
    let profile: UserProfile
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ProfileInfoCardView(profile: profile)
                        InterestCardView(tags: profile.areasOfInterest)
                        PreferenceCardView(tags: profile.learningPreferences)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color(red: 0.78, green: 0.16, blue: 0.16))
                .frame(height: 140)
                .ignoresSafeArea(edges: .top)
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                
                Text("Your Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 70)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(profile: sampleProfile)
        }
    }
}


struct ProfileInfoCardView: View {
    let profile: UserProfile
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle")
                    .foregroundColor(.red)
                Text(profile.name)
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.classYear)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(profile.major)
                    .font(.subheadline)
                
                if let minor = profile.minor {
                    Text(minor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Button(action: {
                // will do later
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct InterestCardView: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.red)
                Text("Areas of Interest")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            TagListView(tags: tags)
            
            Button(action: {
                //will do later
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Edit Areas of Interest")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct PreferenceCardView: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed")
                    .foregroundColor(.red)
                Text("Learning Preferences")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            TagListView(tags: tags)
            
            Button(action: {
                //Will do later
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Edit Preferences")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct TagListView: View {
    let tags: [String]
    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagView(text: tag)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .stroke(Color.primary.opacity(0.25), lineWidth: 1)
            )
    }
}
