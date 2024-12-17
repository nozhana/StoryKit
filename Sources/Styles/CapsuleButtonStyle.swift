//
//  CapsuleButtonStyle.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/16/24.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(16)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(.tint.opacity(configuration.isPressed ? 0.75 : 1), in: .capsule)
    }
}

extension ButtonStyle where Self == CapsuleButtonStyle {
    static var capsule: CapsuleButtonStyle { .init() }
}
