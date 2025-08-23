//
//  ProfileSetupView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/21/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSetupView: View {
    @Binding var isLoggedIn: Bool
    var onProfileSaved: () -> Void
    var user: User
    @EnvironmentObject var theme: AppTheme

    @State private var name = ""
    @State private var age = ""
    @State private var preferredMode = "Text-to-Speech"
    @State private var goals: [String] = []
    @State private var favoriteSound = "Calm"
    @State private var colorSensitive = false
    @State private var dailyBreaks = 3
    @State private var dailyComms = 5
    @State private var emergencyContact = ""
    @State private var errorMessage = ""
    @State private var saving = false

    let goalOptions = ["Reduce Anxiety", "Improve Speech", "Handle Sensory Overload", "Increase Focus"]
    let modes = ["Text-to-Speech", "Visual Cards"]
    let sounds = ["Calm", "White Noise", "Rain"] // removed Nature

    var body: some View {
        Form {
            Section(header: Label("Basic Info", systemImage: "person.circle")) {
                TextField("Name", text: $name)
                TextField("Age", text: $age).keyboardType(.numberPad)
                TextField("Emergency Contact (Optional)", text: $emergencyContact)
            }

            Section(header: Label("Preferences", systemImage: "gearshape")) {
                Picker("Preferred Communication Mode", selection: $preferredMode) {
                    ForEach(modes, id: \.self) { Text($0) }
                }
                Picker("Favorite Calming Sound", selection: $favoriteSound) {
                    ForEach(sounds, id: \.self) { Text($0) }
                }
                Toggle("Color Sensitivity Mode", isOn: $colorSensitive)
            }

            Section(header: Label("Goals", systemImage: "target")) {
                ForEach(goalOptions, id: \.self) { goal in
                    MultipleSelectionRow(title: goal, isSelected: goals.contains(goal)) {
                        if goals.contains(goal) { goals.removeAll { $0 == goal } }
                        else { goals.append(goal) }
                    }
                }
            }

            Section(header: Label("Daily Targets", systemImage: "calendar")) {
                Stepper("Sensory Breaks per Day: \(dailyBreaks)", value: $dailyBreaks, in: 1...10)
                Stepper("Communication Exercises per Day: \(dailyComms)", value: $dailyComms, in: 1...20)
            }

            if saving {
                ProgressView("Saving Profile...")
            } else {
                Button("Save Profile", action: saveProfile)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
        }
        .navigationTitle("Your Profile")
        .preferredColorScheme(colorSensitive ? .light : nil)
        .accentColor(theme.primaryColor)
    }

    func saveProfile() {
        saving = true
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "name": name,
            "age": age,
            "preferredMode": preferredMode,
            "favoriteSound": favoriteSound,
            "colorSensitive": colorSensitive,
            "goals": goals,
            "dailyBreaks": dailyBreaks,
            "dailyComms": dailyComms,
            "emergencyContact": emergencyContact
        ], merge: true) { error in
            saving = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                theme.colorSensitive = colorSensitive // update global theme
                onProfileSaved()
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundColor(.blue)
                }
            }
        }
    }
}
