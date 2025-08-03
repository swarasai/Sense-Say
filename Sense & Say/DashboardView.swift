//
//  DashboardView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 7/30/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var theme: AppTheme
    
    @State private var showGoals = false
    @State private var showDailyTargets = false
    @State private var quote = ""

    let quotes = [
        "You are capable of amazing things.",
        "Progress, not perfection.",
        "Small steps every day lead to big change.",
        "Believe you can, and you're halfway there.",
        "Focus on what you can do, not what you can't."
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: theme.colorSensitive
                                   ? [Color(.systemGray5), Color(.systemGray6)]
                                   : [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Motivational Quote Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("“\(quote)”")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(theme.colorSensitive ? .primary : .white)
                            .transition(.opacity)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.colorSensitive ? Color.white : Color.black.opacity(0.2))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Welcome Card (Uses Profile Name)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome back,")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        // Always use name from profile
                        Text(userProfile.name.isEmpty ? "Welcome!" : userProfile.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(theme.colorSensitive ? .primary : .white)
                            .transition(.opacity)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.colorSensitive ? Color.white : Color.black.opacity(0.2))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    // Goals Card
                    if !userProfile.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Goals")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(userProfile.goals, id: \.self) { goal in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(goal)
                                        .font(.body)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(theme.colorSensitive ? 1 : 0.9))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .opacity(showGoals ? 1 : 0)
                        .animation(.easeInOut.delay(0.3), value: showGoals)
                    }

                    // Daily Targets Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Targets")
                            .font(.title2)
                            .fontWeight(.semibold)
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                            Text("Sensory breaks: \(userProfile.dailyBreaks)")
                        }
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.purple)
                            Text("Communication exercises: \(userProfile.dailyComms)")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(theme.colorSensitive ? 1 : 0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .opacity(showDailyTargets ? 1 : 0)
                    .animation(.easeInOut.delay(0.5), value: showDailyTargets)
                }
                .padding(.vertical, 30)
            }
        }
        .onAppear {
            quote = quotes.randomElement() ?? ""
            withAnimation { showGoals = true }
            withAnimation { showDailyTargets = true }
        }
    }
}
