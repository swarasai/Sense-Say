//
//  LocalPhraseStore.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 8/21/25.
//

import Foundation

enum LocalPhraseStore {
    private static let key = "local_phrases_v1"

    static func load() -> [Phrase] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Phrase].self, from: data)) ?? []
    }

    static func save(_ phrases: [Phrase]) {
        if let data = try? JSONEncoder().encode(phrases) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func add(_ phrase: Phrase) {
        var current = load()
        if !current.contains(where: { $0.text.caseInsensitiveCompare(phrase.text) == .orderedSame }) {
            current.append(phrase)
            save(current)
        }
    }

    static func delete(_ id: String) {
        var current = load()
        current.removeAll { $0.id == id }
        save(current)
    }
}
