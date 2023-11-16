//
//  ButtonViewModifier.swift
//  King IPTV
//
//  Created by Nevzat BOZKURT on 9.09.2023.
//

import SwiftUI

struct RoundedStyleModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat

    init(backgroundColor: Color = .blue, cornerRadius: CGFloat = 15) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .padding([.horizontal, .bottom])
            .foregroundColor(.white)
    }
}

extension View {
    func roundedStyle(backgroundColor: Color = .blue, cornerRadius: CGFloat = 15) -> some View {
        self.modifier(RoundedStyleModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}
