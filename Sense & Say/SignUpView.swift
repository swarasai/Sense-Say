//
//  SignUpView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var disorders = ""
    @State private var calmingStrategies = ""
    @State private var errorMessage = ""

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            TextField("Disorders (comma separated)", text: $disorders)
            TextField("Calming Strategies (comma separated)", text: $calmingStrategies)
            Button("Sign Up") {
                signUp()
            }
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else { return }
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "disorders": disorders.components(separatedBy: ","),
                "calmingStrategies": calmingStrategies.components(separatedBy: ",")
            ]) { err in
                if let err = err {
                    errorMessage = err.localizedDescription
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}
