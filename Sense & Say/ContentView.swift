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
        if isChecking {
            return AnyView(ProgressView("Loading..."))
        } else if !isLoggedIn {
            return AnyView(AuthView { user in
                self.user = user
                profileExists = false
                isLoggedIn = true
            })
        } else if !profileExists, let user = user ?? Auth.auth().currentUser {
            return AnyView(ProfileSetupView(isLoggedIn: $isLoggedIn, onProfileSaved: {
                profileExists = true
            }, user: user))
        } else {
            return AnyView(MainTabView())
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

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
