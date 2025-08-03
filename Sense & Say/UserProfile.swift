//
//  UserProfile.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 7/30/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var preferredMode: String = "Text-to-Speech"
    @Published var favoriteSound: String = "Calm"
    @Published var colorSensitive: Bool = false
    @Published var goals: [String] = []
    @Published var dailyBreaks: Int = 3
    @Published var dailyComms: Int = 5
    @Published var emergencyContact: String = ""

    /// Load profile data from Firestore dictionary
    func load(from data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.preferredMode = data["preferredMode"] as? String ?? "Text-to-Speech"
        self.favoriteSound = data["favoriteSound"] as? String ?? "Calm"
        self.colorSensitive = data["colorSensitive"] as? Bool ?? false
        self.goals = data["goals"] as? [String] ?? []
        self.dailyBreaks = data["dailyBreaks"] as? Int ?? 3
        self.dailyComms = data["dailyComms"] as? Int ?? 5
        self.emergencyContact = data["emergencyContact"] as? String ?? ""
    }

    /// Fetch profile from Firestore for current user
    func loadProfile() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, error in
            if let data = doc?.data() {
                DispatchQueue.main.async {
                    self.load(from: data)
                }
            }
        }
    }
}
