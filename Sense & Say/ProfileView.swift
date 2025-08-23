//
//  ProfileView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//


import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLoginSheet = false

    let goalOptions = ["Reduce Anxiety", "Improve Speech", "Handle Sensory Overload", "Increase Focus"]
    let modes = ["Text-to-Speech", "Visual Cards"]
    let sounds = ["Calm", "White Noise", "Rain"]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: theme.colorSensitive
                                       ? [Color(.systemGray5), Color(.systemGray6)]
                                       : [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Info Section
                        GroupBox(label: Text("Basic Info").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Name", text: $viewModel.name)
                                TextField("Age", text: $viewModel.age).keyboardType(.numberPad)
                                TextField("Emergency Contact (Optional)", text: $viewModel.emergencyContact)
                            }
                        }

                        // Preferences Section
                        GroupBox(label: Text("Preferences").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
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
                        GroupBox(label: Text("Goals").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
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

                        // Daily Targets
                        GroupBox(label: Text("Daily Targets").bold()) {
                            VStack(alignment: .leading, spacing: 12) {
                                Stepper("Sensory Breaks per Day: \(viewModel.dailyBreaks)", value: $viewModel.dailyBreaks, in: 1...10)
                                Stepper("Communication Exercises per Day: \(viewModel.dailyComms)", value: $viewModel.dailyComms, in: 1...20)
                            }
                        }

                        // Error message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage).foregroundColor(.red)
                        }

                        // Save Button
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

                        // ===== Account Deletion (Required by Guideline 5.1.1(v)) =====
                        Button(role: .destructive) {
                            viewModel.requestDeleteAccount = true
                        } label: {
                            Text("Delete Account & Data")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .accessibilityIdentifier("delete_account_button") // helpful for QA
                        .alert("Delete Account?", isPresented: $viewModel.requestDeleteAccount) {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteAccount()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This permanently deletes your account and all associated data.")
                        }
                        // Reauth sheet (shown only if Firebase requires recent login)
                        .sheet(isPresented: $viewModel.showReauthSheet) {
                            ReauthView(
                                email: $viewModel.reauthEmail,
                                password: $viewModel.reauthPassword
                            ) {
                                viewModel.performReauthAndDelete()
                            }
                        }
                        // Success banner/alert
                        .alert("Account Deleted", isPresented: $viewModel.deletionSucceeded) {
                            Button("OK") {
                                // After deletion, show login sheet so user isn't stuck
                                showLoginSheet = true
                            }
                        } message: {
                            Text("Your account and associated data have been removed.")
                        }
                        // ===== End Account Deletion UI =====
                    }
                    .padding()
                }

                // Overlay spinner if loading
                if viewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Processing…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .zIndex(1)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if Auth.auth().currentUser != nil {
                            do { try Auth.auth().signOut() } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                        showLoginSheet = true
                    }) {
                        Text(Auth.auth().currentUser != nil ? "Log Out" : "Log In")
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                AuthView { _ in
                    showLoginSheet = false
                    userProfile.loadProfile()
                }
                .environmentObject(theme)
            }
            .onAppear {
                viewModel.loadProfile(theme: theme, userProfile: userProfile)
            }
        }
    }
}
