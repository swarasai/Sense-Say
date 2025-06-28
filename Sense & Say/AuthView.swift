//
//  AuthView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    var onSignUp: (User) -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Sense & Say")
                .font(.largeTitle)
                .bold()

            Picker("", selection: $isSignUp) {
                Text("Log In").tag(false)
                Text("Sign Up").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button(isSignUp ? "Sign Up" : "Log In") {
                if isSignUp {
                    signUp()
                } else {
                    logIn()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
    }

    func logIn() {
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    errorMessage = "No account found for this email. Please sign up."
                } else {
                    errorMessage = error.localizedDescription
                }
            } else if let user = result?.user {
                // Check if profile exists (handled in ContentView)
                isLoggedIn = true
            }
        }
    }

    func signUp() {
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    errorMessage = "An account with this email already exists."
                } else {
                    errorMessage = error.localizedDescription
                }
            } else if let user = result?.user {
                onSignUp(user)
            }
        }
    }
}
