//
//  ProfileView.swift
//  CourseReview
//
//  Created by Dheeraj Sai Thota on 12/1/25.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var profile: UserProfile = ProfileView.loadProfile()
    @State private var isEditingBasicInfo = false
    @State private var isEditingInterests = false
    @State private var isEditingPreferences = false
    
    private static let profileKey = "userProfile"
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ProfileInfoCardView(
                            profile: profile,
                            onEditTapped: { isEditingBasicInfo = true }
                        )
                        InterestCardView(
                            tags: profile.areasOfInterest,
                            onEditTapped: { isEditingInterests = true }
                        )
                        PreferenceCardView(
                            tags: profile.learningPreferences,
                            onEditTapped: { isEditingPreferences = true }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isEditingBasicInfo) {
            EditProfileSheet(profile: $profile)
        }
        .sheet(isPresented: $isEditingInterests) {
            EditTagsSheet(
                tags: $profile.areasOfInterest,
                title: "Areas of Interest"
            )
        }
        .sheet(isPresented: $isEditingPreferences) {
            EditTagsSheet(
                tags: $profile.learningPreferences,
                title: "Learning Preferences"
            )
        }
        .onAppear {
            profile = ProfileView.loadProfile()
        }
        .onChange(of: profile) { _ in
            saveProfile()
        }
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
    
    private static func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        } else {
            return sampleProfile
        }
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.profileKey)
        }
    }
}

struct ProfileInfoCardView: View {
    let profile: UserProfile
    let onEditTapped: () -> Void
    
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
            
            Button(action: onEditTapped) {
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
    let onEditTapped: () -> Void
    
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
            
            Button(action: onEditTapped) {
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
    let onEditTapped: () -> Void
    
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
            
            Button(action: onEditTapped) {
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

struct EditProfileSheet: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var classYear: String
    @State private var major: String
    @State private var minor: String
    
    init(profile: Binding<UserProfile>) {
        _profile = profile
        _name = State(initialValue: profile.wrappedValue.name)
        _classYear = State(initialValue: profile.wrappedValue.classYear)
        _major = State(initialValue: profile.wrappedValue.major)
        _minor = State(initialValue: profile.wrappedValue.minor ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Class Year", text: $classYear)
                    TextField("Major", text: $major)
                    TextField("Minor (optional)", text: $minor)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile.name = name
                        profile.classYear = classYear
                        profile.major = major
                        let trimmedMinor = minor.trimmingCharacters(in: .whitespacesAndNewlines)
                        profile.minor = trimmedMinor.isEmpty ? nil : trimmedMinor
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditTagsSheet: View {
    @Binding var tags: [String]
    let title: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var newTag: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Current \(title)")) {
                    if tags.isEmpty {
                        Text("No items yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tags.indices, id: \.self) { index in
                            HStack {
                                Text(tags[index])
                                Spacer()
                                Button(role: .destructive) {
                                    tags.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                
                Section(header: Text("Add New")) {
                    HStack {
                        TextField("Enter new item", text: $newTag)
                        Button("Add") {
                            addTag()
                        }
                        .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if !tags.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            tags.append(trimmed)
        }
        newTag = ""
    }
}
