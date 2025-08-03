//
//  CommunicationHelperView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

struct Phrase: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var colorIndex: Int
    var iconName: String?
    
    init(id: String = UUID().uuidString, text: String, colorIndex: Int = Int.random(in: 0..<5), iconName: String? = nil) {
        self.id = id
        self.text = text
        self.colorIndex = colorIndex
        self.iconName = iconName
    }
}

struct CommunicationHelperView: View {
    @State private var customPhrases: [Phrase] = []
    @State private var selectedPhrases: [Phrase] = []
    @State private var newPhraseText = ""
    @State private var showDeleteAlert: Bool = false
    @State private var phraseToDelete: Phrase?

    @State private var preferredMode = "Text-to-Speech"
    @State private var enlargeCards = false
    @State private var colorSensitive = false

    let synthesizer = AVSpeechSynthesizer()
    let pastelColors: [Color] = [
        Color(red: 0.9, green: 0.95, blue: 1.0),
        Color(red: 1.0, green: 0.9, blue: 0.95),
        Color(red: 0.95, green: 1.0, blue: 0.9),
        Color(red: 1.0, green: 1.0, blue: 0.9),
        Color(red: 0.95, green: 0.9, blue: 1.0)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Build a Sentence")
                        .font(colorSensitive ? .title2 : .largeTitle)
                        .fontWeight(colorSensitive ? .regular : .bold)

                    // Selected Phrases Row + Speak/Clear Buttons
                    VStack(alignment: .leading, spacing: 12) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedPhrases, id: \.id) { phrase in
                                    Text(phrase.text)
                                        .font(.headline)
                                        .padding(10)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }

                        if preferredMode == "Text-to-Speech" {
                            HStack {
                                Button("Speak") {
                                    speak(selectedPhrases.map { $0.text }.joined(separator: " "))
                                }
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)

                                Button("Clear") { withAnimation { selectedPhrases.removeAll() } }
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button("Clear") { withAnimation { selectedPhrases.removeAll() } }
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Phrase Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text(preferredMode == "Visual Cards" ? "Tap to Add Visual Cards" : "Tap to Add & Speak")
                            .font(.title2)
                            .fontWeight(.semibold)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: enlargeCards ? 160 : 120))], spacing: 12) {
                            ForEach(customPhrases) { phrase in
                                Button(action: { handlePhraseTap(phrase) }) {
                                    VStack {
                                        if preferredMode == "Visual Cards", let icon = phrase.iconName {
                                            Image(systemName: icon)
                                                .font(.largeTitle)
                                        }
                                        Text(phrase.text)
                                            .font(.body)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: enlargeCards ? 80 : 44)
                                    .padding()
                                    .background(
                                        (colorSensitive
                                         ? pastelColors[phrase.colorIndex % pastelColors.count].opacity(0.7)
                                         : pastelColors[phrase.colorIndex % pastelColors.count])
                                    )
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                }
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        phraseToDelete = phrase
                                        showDeleteAlert = true
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Add Phrase Row
                    VStack {
                        HStack {
                            TextField("Add a new phrase", text: $newPhraseText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Add") { addPhrase() }
                                .disabled(newPhraseText.isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .appBackground()
            .navigationTitle("Custom Word Board")
        }
        .onAppear {
            loadProfilePreferences()
            loadPhrases()
        }
        .alert("Delete Phrase?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let phrase = phraseToDelete { deletePhrase(phrase) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this phrase?")
        }
    }

    func handlePhraseTap(_ phrase: Phrase) {
        if preferredMode == "Text-to-Speech" { speak(phrase.text) }
        selectedPhrases.append(phrase)
    }

    func speak(_ text: String) {
        guard preferredMode == "Text-to-Speech" else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice.speechVoices().first
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }

    func addPhrase() {
        guard let user = Auth.auth().currentUser else { return }
        if customPhrases.contains(where: { $0.text == newPhraseText }) { return }
        let newPhrase = Phrase(text: newPhraseText, iconName: "textformat")
        customPhrases.append(newPhrase)
        newPhraseText = ""
        Firestore.firestore()
            .collection("users").document(user.uid)
            .collection("phrases").document(newPhrase.id)
            .setData([
                "text": newPhrase.text,
                "colorIndex": newPhrase.colorIndex,
                "iconName": newPhrase.iconName ?? ""
            ])
    }

    func deletePhrase(_ phrase: Phrase) {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore()
            .collection("users").document(user.uid)
            .collection("phrases").document(phrase.id).delete()
        customPhrases.removeAll { $0.id == phrase.id }
    }

    func loadPhrases() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore()
            .collection("users").document(user.uid)
            .collection("phrases").getDocuments { snapshot, _ in
                if let docs = snapshot?.documents {
                    customPhrases = docs.compactMap { doc in
                        let data = doc.data()
                        if let text = data["text"] as? String {
                            let colorIndex = data["colorIndex"] as? Int ?? Int.random(in: 0..<pastelColors.count)
                            let iconName = data["iconName"] as? String
                            return Phrase(id: doc.documentID, text: text, colorIndex: colorIndex, iconName: iconName)
                        }
                        return nil
                    }
                }
            }
    }

    func loadProfilePreferences() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
            if let data = doc?.data() {
                preferredMode = data["preferredMode"] as? String ?? "Text-to-Speech"
                colorSensitive = data["colorSensitive"] as? Bool ?? false
                enlargeCards = (preferredMode == "Visual Cards") || colorSensitive
            }
        }
    }
}
