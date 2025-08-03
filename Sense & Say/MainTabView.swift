//
//  MainTabView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CommunicationHelperView()
                .tabItem {
                    Label("Communicate", systemImage: "message")
                }

            SensoryRegulationView()
                .tabItem {
                    Label("Regulation", systemImage: "wind")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .transition(.opacity)
    }
}
