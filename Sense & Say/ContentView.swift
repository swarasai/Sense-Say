//
//  ContentView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/18/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            AuthView(isLoggedIn: $isLoggedIn)
        }
    }
}
