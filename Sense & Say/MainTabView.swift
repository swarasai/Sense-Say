//
//  MainTabView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
                .onAppear { userProfile.loadProfile() }
            CommunicationHelperView()
                .tabItem { Label("Communicate", systemImage: "message") }
                .tag(1)
            SensoryRegulationView()
                .tabItem { Label("Regulation", systemImage: "wind") }
                .tag(2)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(3)
                .onAppear { userProfile.loadProfile() }
        }
        .onChange(of: selectedTab) { _ in
            userProfile.loadProfile()
        }
    }
}
