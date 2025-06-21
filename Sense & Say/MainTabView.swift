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
            SensoryRegulationView()
                .tabItem { Label("Regulation", systemImage: "wind") }
            CommunicationHelperView()
                .tabItem { Label("Communicate", systemImage: "message") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
