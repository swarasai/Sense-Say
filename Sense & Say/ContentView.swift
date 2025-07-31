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
    @State private var isChecking = true
    @State private var user: User?

    var body: some View {
        Group {
            if isChecking {
                ProgressView("Loading...")
            } else if !isLoggedIn {
                AuthView(isLoggedIn: $isLoggedIn) { user in
                    self.user = user
                    profileExists = false
                    isLoggedIn = true
                }
            } else if !profileExists, let user = user ?? Auth.auth().currentUser {
                ProfileSetupView(isLoggedIn: $isLoggedIn, onProfileSaved: {
                    profileExists = true
                }, user: user)
            } else {
                MainTabView()
            }
        }
        .onAppear(perform: checkAuthState)
        .onChange(of: isLoggedIn) { loggedIn in
            if loggedIn { checkProfile() }
        }
    }

    private func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            user = currentUser
            isLoggedIn = true
            checkProfile()
        } else {
            isLoggedIn = false
            isChecking = false
        }
    }

    private func checkProfile() {
        guard let user = Auth.auth().currentUser else {
            profileExists = false
            isChecking = false
            return
        }
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
            profileExists = doc?.exists ?? false
            isChecking = false
        }
    }
}
