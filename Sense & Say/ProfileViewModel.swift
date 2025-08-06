//
//  ProfileViewModel.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 7/30/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var age = ""
    @Published var preferredMode = "Text-to-Speech"
    @Published var favoriteSound = "Calm"
    @Published var colorSensitive = false
    @Published var goals: [String] = []
    @Published var dailyBreaks = 3
    @Published var dailyComms = 5
    @Published var emergencyContact = ""
    @Published var isLoading = false
    @Published var errorMessage = ""

    func loadProfile(theme: AppTheme, userProfile: UserProfile) {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = doc?.data() {
                    self.name = data["name"] as? String ?? ""
                    self.age = data["age"] as? String ?? ""
                    self.preferredMode = data["preferredMode"] as? String ?? "Text-to-Speech"
                    self.favoriteSound = data["favoriteSound"] as? String ?? "Calm"
                    self.colorSensitive = data["colorSensitive"] as? Bool ?? false
                    self.goals = data["goals"] as? [String] ?? []
                    self.dailyBreaks = data["dailyBreaks"] as? Int ?? 3
                    self.dailyComms = data["dailyComms"] as? Int ?? 5
                    self.emergencyContact = data["emergencyContact"] as? String ?? ""
                    theme.colorSensitive = self.colorSensitive
                    userProfile.load(from: data)
                }
            }
        }
    }

    func saveProfile(theme: AppTheme, userProfile: UserProfile) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "Not logged in"
            return
        }
        isLoading = true
        errorMessage = ""
        Firestore.firestore().collection("users").document(user.uid).setData([
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
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Save failed: \(error.localizedDescription)"
                } else {
                    theme.colorSensitive = self.colorSensitive
                    userProfile.loadProfile()
                }
            }
        }
    }
}
