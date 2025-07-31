//
//  ProfileView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var theme: AppTheme
    @StateObject private var viewModel = ProfileViewModel()

    let goalOptions = ["Reduce Anxiety", "Improve Speech", "Handle Sensory Overload", "Increase Focus"]
    let modes = ["Text-to-Speech", "Sign Language Helper", "Visual Cards"]
    let sounds = ["Calm", "White Noise", "Rain"]

    var body: some View {
        Form {
            Section(header: Label("Basic Info", systemImage: "person.circle")) {
                TextField("Name", text: $viewModel.name)
                TextField("Age", text: $viewModel.age).keyboardType(.numberPad)
                TextField("Emergency Contact (Optional)", text: $viewModel.emergencyContact)
            }

            Section(header: Label("Preferences", systemImage: "gearshape")) {
                Picker("Preferred Communication Mode", selection: $viewModel.preferredMode) {
                    ForEach(modes, id: \.self) { Text($0) }
                }
                Picker("Favorite Calming Sound", selection: $viewModel.favoriteSound) {
                    ForEach(sounds, id: \.self) { Text($0) }
                }
                Toggle("Color Sensitivity Mode", isOn: $viewModel.colorSensitive)
            }

            Section(header: Label("Goals", systemImage: "target")) {
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

            Section(header: Label("Daily Targets", systemImage: "calendar")) {
                Stepper("Sensory Breaks per Day: \(viewModel.dailyBreaks)", value: $viewModel.dailyBreaks, in: 1...10)
                Stepper("Communication Exercises per Day: \(viewModel.dailyComms)", value: $viewModel.dailyComms, in: 1...20)
            }

            if viewModel.isLoading {
                ProgressView("Saving...")
            } else {
                Button("Save Changes") {
                    viewModel.saveProfile(theme: theme)
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage).foregroundColor(.red)
            }
        }
        .onAppear { viewModel.loadProfile(theme: theme) }
        .preferredColorScheme(theme.colorSensitive ? .light : nil)
        .accentColor(theme.primaryColor)
        .navigationTitle("Profile")
    }
}
