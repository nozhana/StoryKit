//
//  File.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/13/24.
//

import SwiftUI

struct StoryStackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

extension ButtonStyle where Self == StoryStackButtonStyle {
    static var storyStack: Self { .init() }
}
