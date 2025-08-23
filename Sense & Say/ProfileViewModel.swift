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
    // Existing profile fields
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

    // Deletion flow state
    @Published var requestDeleteAccount = false
    @Published var showReauthSheet = false
    @Published var reauthEmail = ""
    @Published var reauthPassword = ""
    @Published var deletionSucceeded = false

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

    // MARK: - Account Deletion

    /// Deletes Firestore user doc (+ phrases subcollection) and then deletes the Firebase Auth user.
    /// If recent login is required, prompts reauth.
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "Not logged in."
            return
        }
        isLoading = true
        errorMessage = ""
        let uid = user.uid
        let db = Firestore.firestore()

        // 1) Delete subcollection "phrases"
        db.collection("users").document(uid).collection("phrases").getDocuments { snap, err in
            if let err = err {
                self.finishDeleteWithError("Failed to list phrases: \(err.localizedDescription)")
                return
            }

            let batch = db.batch()
            snap?.documents.forEach { batch.deleteDocument($0.reference) }

            // 2) Delete user doc
            batch.deleteDocument(db.collection("users").document(uid))

            batch.commit { err in
                if let err = err {
                    self.finishDeleteWithError("Failed to delete data: \(err.localizedDescription)")
                    return
                }

                // 3) Delete Auth user
                user.delete { error in
                    if let error = error as NSError?,
                       error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        // Need reauth
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.showReauthSheet = true
                            // Prefill email if available from Auth
                            self.reauthEmail = user.email ?? ""
                        }
                    } else if let error = error {
                        self.finishDeleteWithError("Failed to delete account: \(error.localizedDescription)")
                    } else {
                        self.finishDeleteSuccess()
                    }
                }
            }
        }
    }

    /// Called after reauth sheet submits.
    func performReauthAndDelete() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        errorMessage = ""

        let credential = EmailAuthProvider.credential(withEmail: reauthEmail, password: reauthPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                self.finishDeleteWithError("Reauthentication failed: \(error.localizedDescription)")
                return
            }
            // After reauth, try delete again
            user.delete { error in
                if let error = error {
                    self.finishDeleteWithError("Failed to delete account: \(error.localizedDescription)")
                } else {
                    self.finishDeleteSuccess()
                }
            }
        }
    }

    private func finishDeleteSuccess() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.deletionSucceeded = true
            self.requestDeleteAccount = false
            self.showReauthSheet = false
            // Clear local state
            self.name = ""; self.age = ""; self.goals = []
            self.favoriteSound = "Calm"; self.preferredMode = "Text-to-Speech"
            self.colorSensitive = false; self.dailyBreaks = 3; self.dailyComms = 5
        }
    }

    private func finishDeleteWithError(_ message: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
        }
    }
}
