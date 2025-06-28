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
    var id: String = UUID().uuidString
    var text: String
    var colorIndex: Int = Int.random(in: 0..<5)
}

struct CommunicationHelperView: View {
    @State private var customPhrases: [Phrase] = []
    @State private var selectedPhrases: [Phrase] = []
    @State private var newPhraseText = ""
    @State private var showDeleteAlert: Bool = false
    @State private var phraseToDelete: Phrase?

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
            VStack(spacing: 16) {
                Text("Build a Sentence")
                    .font(.largeTitle)
                    .bold()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(selectedPhrases.enumerated()), id: \.element.id) { index, phrase in
                            Text(phrase.text)
                                .font(.headline)
                                .padding(10)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .onDrag {
                                    NSItemProvider(object: NSString(string: phrase.text))
                                }
                                .onDrop(of: [.text], delegate: PhraseDropDelegate(item: phrase, items: $selectedPhrases, currentIndex: index))
                        }
                    }
                    .padding(.horizontal)
                }

                HStack {
                    Button("Speak") {
                        speak(selectedPhrases.map { $0.text }.joined(separator: " "))
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Clear") {
                        selectedPhrases.removeAll()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Divider()

                Text("Tap to Add & Speak")
                    .font(.title2)
                    .bold()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    ForEach(customPhrases) { phrase in
                        Button(action: {
                            speak(phrase.text)
                            selectedPhrases.append(phrase)
                        }) {
                            Text(phrase.text)
                                .font(.body)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding()
                                .background(pastelColors[phrase.colorIndex % pastelColors.count])
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
                .padding()

                HStack {
                    TextField("Add a new phrase", text: $newPhraseText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        addPhrase()
                    }
                    .disabled(newPhraseText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Custom Word Board")
        }
        .onAppear(perform: loadPhrases)
        .alert("Delete Phrase?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let phrase = phraseToDelete {
                    deletePhrase(phrase)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this phrase?")
        }
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }

    func addPhrase() {
        guard let user = Auth.auth().currentUser else { return }
        let newPhrase = Phrase(text: newPhraseText)
        customPhrases.append(newPhrase)
        newPhraseText = ""

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("phrases").document(newPhrase.id).setData([
            "text": newPhrase.text,
            "colorIndex": newPhrase.colorIndex
        ])
    }

    func deletePhrase(_ phrase: Phrase) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("phrases").document(phrase.id).delete()
        customPhrases.removeAll { $0.id == phrase.id }
    }

    func loadPhrases() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("phrases").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                customPhrases = documents.compactMap { doc in
                    let data = doc.data()
                    if let text = data["text"] as? String {
                        let colorIndex = data["colorIndex"] as? Int ?? Int.random(in: 0..<pastelColors.count)
                        return Phrase(id: doc.documentID, text: text, colorIndex: colorIndex)
                    }
                    return nil
                }
            }
        }
    }
}

struct PhraseDropDelegate: DropDelegate {
    let item: Phrase
    @Binding var items: [Phrase]
    let currentIndex: Int

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let fromIndex = items.firstIndex(of: item),
              let itemProvider = info.itemProviders(for: [.text]).first else { return }

        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, _ in
            DispatchQueue.main.async {
                guard let data = data as? Data,
                      let draggedText = String(data: data, encoding: .utf8),
                      let draggedItem = items.first(where: { $0.text == draggedText }),
                      let draggedIndex = items.firstIndex(of: draggedItem) else { return }

                items.move(fromOffsets: IndexSet(integer: draggedIndex), toOffset: currentIndex > draggedIndex ? currentIndex + 1 : currentIndex)
            }
        }
    }
}
