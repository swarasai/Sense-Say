//
//  LoginView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        Form {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Log In") {
                login()
            }
            Button("Sign in with Google") {
                // Implement Google Sign-In here
            }
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
