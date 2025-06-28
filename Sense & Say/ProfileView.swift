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
    @State private var anxiety = 0.0
    @State private var speech = 0.0
    @State private var sensory = 0.0
    @State private var focus = 0.0
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Name", text: $name)
                TextField("Disorders", text: $disorders)
                TextField("Calming Strategies", text: $calmingStrategies)
            }

            Section(header: Text("Struggles")) {
                SliderView(label: "Anxiety", value: $anxiety)
                SliderView(label: "Speech", value: $speech)
                SliderView(label: "Sensory", value: $sensory)
                SliderView(label: "Focus", value: $focus)
            }

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
        db.collection("users").document(user.uid).getDocument { doc, _ in
            if let data = doc?.data() {
                name = data["name"] as? String ?? ""
                disorders = (data["disorders"] as? [String])?.joined(separator: ",") ?? ""
                calmingStrategies = (data["calmingStrategies"] as? [String])?.joined(separator: ",") ?? ""

                if let struggles = data["struggles"] as? [String: Double] {
                    anxiety = struggles["anxiety"] ?? 0
                    speech = struggles["speech"] ?? 0
                    sensory = struggles["sensory"] ?? 0
                    focus = struggles["focus"] ?? 0
                }
            }
        }
    }

    func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "name": name,
            "disorders": disorders.components(separatedBy: ","),
            "calmingStrategies": calmingStrategies.components(separatedBy: ","),
            "struggles": [
                "anxiety": anxiety,
                "speech": speech,
                "sensory": sensory,
                "focus": focus
            ]
        ]) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}
