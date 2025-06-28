//
//  SliderView.swift
//  Sense & Say
//
//  Created by Swarasai Mulagari on 6/21/25.
//

import SwiftUI

struct SliderView: View {
    var label: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(Int(value))")
            Slider(value: $value, in: 1...10, step: 1)
        }
        .padding(.vertical, 4)
    }
}
