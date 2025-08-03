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
    private var hasLoaded = false

    func loadProfile(theme: AppTheme, userProfile: UserProfile) {
        guard !hasLoaded, let user = Auth.auth().currentUser else { return }
        isLoading = true
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
            self.isLoading = false
            self.hasLoaded = true
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

    func saveProfile(theme: AppTheme, userProfile: UserProfile) {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
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
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                theme.colorSensitive = self.colorSensitive
                
                // Directly update userProfile used by HomeView
                userProfile.name = self.name
                userProfile.preferredMode = self.preferredMode
                userProfile.favoriteSound = self.favoriteSound
                userProfile.goals = self.goals
                userProfile.dailyBreaks = self.dailyBreaks
                userProfile.dailyComms = self.dailyComms
                userProfile.colorSensitive = self.colorSensitive
            }
        }
    }
}
