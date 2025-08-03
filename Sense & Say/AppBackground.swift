//
//  AppBackground.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 8/3/25.
//

import SwiftUI

struct AppBackground: ViewModifier {
    @EnvironmentObject var theme: AppTheme
    
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: theme.colorSensitive
                                   ? [Color(.systemGray5), Color(.systemGray6)]
                                   : [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        self.modifier(AppBackground())
    }
}
