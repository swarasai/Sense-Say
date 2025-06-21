//
//  ProfileView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var name = ""
    @State private var disorders = ""
    @State private var calmingStrategies = ""
    @State private var errorMessage = ""

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Disorders", text: $disorders)
            TextField("Calming Strategies", text: $calmingStrategies)
            Button("Save Changes") {
                saveProfile()
            }
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
        }
        .onAppear(perform: loadProfile)
    }

    func loadProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { doc, error in
            if let data = doc?.data() {
                name = data["name"] as? String ?? ""
                disorders = (data["disorders"] as? [String])?.joined(separator: ",") ?? ""
                calmingStrategies = (data["calmingStrategies"] as? [String])?.joined(separator: ",") ?? ""
            }
        }
    }

    func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "name": name,
            "disorders": disorders.components(separatedBy: ","),
            "calmingStrategies": calmingStrategies.components(separatedBy: ",")
        ]) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}
