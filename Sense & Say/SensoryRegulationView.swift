//
//  SensoryRegulationView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import AVFoundation

struct SensoryRegulationView: View {
    @State private var isPlaying = false
    var player: AVAudioPlayer?

    func playSound() {
        guard let url = Bundle.main.url(forResource: "calm", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Error playing audio.")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Calm Me")
                .font(.title)

            Button("Calm Me Down") {
                playSound()
            }

            Button("Start Sensory Break") {
                // Add break timer or animation here
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }
}
