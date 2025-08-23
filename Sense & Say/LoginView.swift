//
//  LoginView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    var onLogin: (User) -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    @EnvironmentObject var theme: AppTheme // To apply same theme-based gradient

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient same as other tabs
                LinearGradient(
                    gradient: Gradient(colors: theme.colorSensitive
                                       ? [Color(.systemGray5), Color(.systemGray6)]
                                       : [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Login Form content
                Form {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password)

                    Button("Log In") {
                        login()
                    }
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .scrollContentBackground(.hidden)  // Hide Form default background to show gradient
            }
            .navigationTitle("Log In")
        }
    }

    func login() {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let user = result?.user {
                    onLogin(user)
                } else if let error = error {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
