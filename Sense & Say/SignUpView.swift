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
    @State private var disorders = ""
    @State private var calmingStrategies = ""
    @State private var anxiety = 5.0
    @State private var speech = 5.0
    @State private var sensory = 5.0
    @State private var focus = 5.0
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Your Info")) {
                TextField("Name", text: $name)
                TextField("Disorders (comma separated)", text: $disorders)
                TextField("Calming Strategies (comma separated)", text: $calmingStrategies)
            }

            Section(header: Text("What do you struggle with? (1-10)")) {
                SliderView(label: "Anxiety", value: $anxiety)
                SliderView(label: "Speech", value: $speech)
                SliderView(label: "Sensory Overload", value: $sensory)
                SliderView(label: "Focus", value: $focus)
            }

            Button("Submit Profile") {
                saveProfile()
            }

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
        }
    }

    func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
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
            } else {
                isLoggedIn = true
            }
        }
    }
}
