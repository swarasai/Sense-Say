//
//  AppTheme.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 7/30/25.
//

import SwiftUI

class AppTheme: ObservableObject {
    @Published var colorSensitive = false

    // Softer color palette for sensitive mode
    var primaryColor: Color {
        colorSensitive ? Color.blue.opacity(0.7) : .blue
    }
    
    var backgroundColor: Color {
        colorSensitive ? Color(.systemGray6) : Color(.systemGroupedBackground)
    }
    
    var cardBackground: Color {
        colorSensitive ? Color(.systemGray5) : Color.gray.opacity(0.2)
    }
    
    var fontWeight: Font.Weight {
        colorSensitive ? .regular : .bold
    }
}
