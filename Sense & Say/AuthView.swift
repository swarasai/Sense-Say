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
    enum Mode {
        case login, signup
    }

    var onAuthSuccess: (User) -> Void

    @EnvironmentObject var theme: AppTheme

    @State private var mode: Mode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""            // For sign up
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: theme.colorSensitive
                                       ? [Color(.systemGray5), Color(.systemGray6)]
                                       : [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Picker("", selection: $mode) {
                        Text("Log In").tag(Mode.login)
                        Text("Sign Up").tag(Mode.signup)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Form {
                        if mode == .signup {
                            TextField("Name", text: $name)
                        }
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)

                        SecureField("Password", text: $password)

                        if !errorMessage.isEmpty {
                            Text(errorMessage).foregroundColor(.red)
                        }

                        Button(mode == .login ? "Log In" : "Create Account") {
                            if mode == .login {
                                login()
                            } else {
                                signUp()
                            }
                        }
                        .disabled(isLoading)
                    }
                    .scrollContentBackground(.hidden)

                    if isLoading {
                        ProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle(mode == .login ? "Log In" : "Create Account")
        }
    }

    // Log In function
    func login() {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let user = result?.user {
                    onAuthSuccess(user)
                } else if let error = error {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Sign Up function
    func signUp() {
        guard !name.isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                } else if let user = result?.user {
                    // Save additional user info to Firestore
                    let data: [String: Any] = [
                        "name": name,
                        "email": email,
                        "preferredMode": "Text-to-Speech",
                        "favoriteSound": "Calm",
                        "colorSensitive": false,
                        "goals": [],
                        "dailyBreaks": 3,
                        "dailyComms": 5,
                        "emergencyContact": ""
                    ]
                    Firestore.firestore()
                        .collection("users")
                        .document(user.uid)
                        .setData(data) { error in
                            DispatchQueue.main.async {
                                self.isLoading = false
                                if let error = error {
                                    self.errorMessage = "Failed to save profile info: \(error.localizedDescription)"
                                } else {
                                    onAuthSuccess(user)
                                }
                            }
                        }
                }
            }
        }
    }
}
