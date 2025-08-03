//
//  ProfileView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var viewModel = ProfileViewModel()

    let goalOptions = ["Reduce Anxiety", "Improve Speech", "Handle Sensory Overload", "Increase Focus"]
    let modes = ["Text-to-Speech", "Visual Cards"]
    let sounds = ["Calm", "White Noise", "Rain"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Basic Info Section
                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Basic Info", systemImage: "person.circle")
                            .font(.headline)
                        TextField("Name", text: $viewModel.name)
                        TextField("Age", text: $viewModel.age).keyboardType(.numberPad)
                        TextField("Emergency Contact (Optional)", text: $viewModel.emergencyContact)
                    }
                }
                
                // Preferences Section
                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Preferences", systemImage: "gearshape")
                            .font(.headline)
                        Picker("Preferred Communication Mode", selection: $viewModel.preferredMode) {
                            ForEach(modes, id: \.self) { Text($0) }
                        }
                        Picker("Favorite Calming Sound", selection: $viewModel.favoriteSound) {
                            ForEach(sounds, id: \.self) { Text($0) }
                        }
                        Toggle("Color Sensitivity Mode", isOn: $viewModel.colorSensitive)
                    }
                }
                
                // Goals Section
                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Goals", systemImage: "target")
                            .font(.headline)
                        ForEach(goalOptions, id: \.self) { goal in
                            MultipleSelectionRow(title: goal, isSelected: viewModel.goals.contains(goal)) {
                                if viewModel.goals.contains(goal) {
                                    viewModel.goals.removeAll { $0 == goal }
                                } else {
                                    viewModel.goals.append(goal)
                                }
                            }
                        }
                    }
                }
                
                // Daily Targets Section
                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Daily Targets", systemImage: "calendar")
                            .font(.headline)
                        Stepper("Sensory Breaks per Day: \(viewModel.dailyBreaks)", value: $viewModel.dailyBreaks, in: 1...10)
                        Stepper("Communication Exercises per Day: \(viewModel.dailyComms)", value: $viewModel.dailyComms, in: 1...20)
                    }
                }

                // Save Button
                if viewModel.isLoading {
                    ProgressView("Saving...")
                } else {
                    Button("Save Changes") {
                        withAnimation {
                            viewModel.saveProfile(theme: theme, userProfile: userProfile)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red)
                }
            }
            .padding()
        }
        .appBackground()
        .navigationTitle("Profile")
        .onAppear { viewModel.loadProfile(theme: theme, userProfile: userProfile) }
    }
}

/// Reusable card wrapper to keep style consistent
struct SectionCard<Content: View>: View {
    @EnvironmentObject var theme: AppTheme
    var content: () -> Content
    
    var body: some View {
        VStack {
            content()
        }
        .padding()
        .background(Color.white.opacity(theme.colorSensitive ? 1 : 0.9))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
