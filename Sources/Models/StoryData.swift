//
//  StoryData.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import struct Foundation.UUID
import SwiftUICore

public struct StoryData: Identifiable, Hashable {
    public let id = UUID()
    public var label: AnyView
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(image: String) {
        self.label = AnyView(
            Image(image)
                .resizable()
                .scaledToFit()
        )
    }
    
    public init(systemImage: String) {
        self.label = AnyView(
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .imageScale(.large)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(colors: [.red, .orange, .red, .orange], startPoint: .bottomLeading, endPoint: .topTrailing))
        )
    }
    
    public init(label: @escaping () -> some View) {
        self.label = AnyView(
            label()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaledToFit()
        )
    }
    
    public init(label: some View) {
        self.label = AnyView(
            label
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaledToFit()
        )
    }
}
