//
//  VerticalLabelStyle.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/16/24.
//

import SwiftUI

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static var titleAndIconVertical: Self { .init() }
}
