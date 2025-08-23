//
//  ReauthView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 8/21/25.
//


import SwiftUI

struct ReauthView: View {
    @Binding var email: String
    @Binding var password: String
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Confirm Your Credentials")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                }
                Section(footer: Text("For your security, reauthentication is required before deleting your account.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Reauthenticate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        onConfirm()
                        // Dismiss is called by parent on success/failure as appropriate
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
        }
    }
}
