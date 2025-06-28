//
//  ContentView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var profileExists = false
    @State private var isCheckingAuth = true
    @State private var isCheckingProfile = false
    @State private var user: User?

    var body: some View {
        Group {
            if isCheckingAuth {
                ProgressView("Checking authentication...")
            } else if !isLoggedIn {
                AuthView(isLoggedIn: $isLoggedIn, onSignUp: { user in
                    self.user = user
                    self.profileExists = false
                    self.isLoggedIn = true
                })
            } else if isCheckingProfile {
                ProgressView("Checking profile...")
            } else if !profileExists, let user = user ?? Auth.auth().currentUser {
                ProfileSetupView(isLoggedIn: $isLoggedIn, onProfileSaved: {
                    self.profileExists = true
                }, user: user)
            } else {
                MainTabView()
            }
        }
        .onAppear {
            checkAuthState()
        }
        .onChange(of: isLoggedIn) { newValue in
            if newValue {
                checkProfile()
            }
        }
    }

    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            isLoggedIn = true
            user = currentUser
            checkProfile()
        } else {
            isLoggedIn = false
            isCheckingAuth = false
        }
    }

    func checkProfile() {
        guard let user = Auth.auth().currentUser else {
            profileExists = false
            isCheckingAuth = false
            return
        }
        isCheckingProfile = true
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { doc, _ in
            profileExists = doc?.exists ?? false
            isCheckingProfile = false
            isCheckingAuth = false
        }
    }
}
