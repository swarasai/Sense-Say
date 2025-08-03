//
//  SensoryRegulationView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

struct SensoryRegulationView: View {
    @State private var favoriteSound = "calm"
    @State private var isLooping = false
    @State private var player: AVAudioPlayer?
    @State private var breakTime: Int = 300
    @State private var timeRemaining = 300
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var showAlert = false
    @State private var animateBreath = false
    @State private var colorSensitive = false

    let availableSounds = ["calm", "white_noise", "rain"]

    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Sensory Regulation Coach")
                        .font(colorSensitive ? .title2 : .largeTitle)
                        .fontWeight(colorSensitive ? .regular : .bold)

                    // Sound controls
                    VStack(spacing: 16) {
                        Picker("Select Sound", selection: $favoriteSound) {
                            ForEach(availableSounds, id: \.self) {
                                Text($0.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Toggle("Loop Playback", isOn: $isLooping)
                        Button("Calm Me Down") { playSound(named: favoriteSound) }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        Button("Stop Sound") { stopSound() }
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.white.opacity(colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Breathing circle
                    VStack {
                        ZStack {
                            Circle()
                                .fill(colorSensitive ? Color.purple.opacity(0.1) : Color.purple.opacity(0.2))
                                .frame(width: animateBreath ? 180 : 120, height: animateBreath ? 180 : 120)
                                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateBreath)
                            Text("Breathe").font(.headline)
                        }
                        .onAppear { animateBreath = true }
                    }
                    .padding()
                    .background(Color.white.opacity(colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Timer
                    VStack(spacing: 16) {
                        Text("Sensory Break Timer")
                            .font(.title2)
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                        HStack(spacing: 20) {
                            Button(isTimerRunning ? "Pause" : "Start") {
                                isTimerRunning ? pauseTimer() : startTimer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            Button("Reset") { resetTimer() }
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Time's Up!"), message: Text("Your sensory break has ended."), dismissButton: .default(Text("OK")))
            }
            .onAppear { loadProfilePreferences() }
        }

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound file not found.")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = isLooping ? -1 : 0
            player?.play()
        } catch {
            print("Error playing audio.")
        }
    }

    func stopSound() {
        player?.stop()
    }

    func startTimer() {
        if timeRemaining == 0 { timeRemaining = breakTime }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isTimerRunning = false
                showAlert = true
            }
        }
        isTimerRunning = true
    }

    func pauseTimer() {
        timer?.invalidate()
        isTimerRunning = false
    }

    func resetTimer() {
        timer?.invalidate()
        timeRemaining = breakTime
        isTimerRunning = false
    }

    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    func loadProfilePreferences() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
            if let data = doc?.data() {
                favoriteSound = (data["favoriteSound"] as? String)?.lowercased() ?? "calm"
                colorSensitive = data["colorSensitive"] as? Bool ?? false
            }
        }
    }
}
