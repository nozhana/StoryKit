//
//  StoryBundle.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/7/24.
//

import SwiftUI

public struct StoryBundle: View {
    var bundle: StoryBundleData
    var progress: CGFloat
    var isPressed: Bool
    
    public init(bundle: StoryBundleData, progress: CGFloat, isPressed: Bool = false) {
        self.bundle = bundle
        self.progress = progress
        self.isPressed = isPressed
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Color.black
                    .clipShape(.rect(cornerRadius: 8))
                
                let index = min(Int(progress), bundle.stories.count - 1)
                let story = bundle.stories[index]
                
                story.label
                    .frame(maxHeight: geometry.size.height, alignment: .center)
                
                HStack {
                    bundle.profileView
                        .frame(width: 35, height: 35)
                        .clipShape(.circle)
                    
                    Text("@\(bundle.profileName)")
                        .bold()
                        .foregroundStyle(.white)
                    
                    Spacer()
                } // HStack
                .padding()
                .offset(y: 8)
                
                HStack(spacing: 6) {
                    ForEach(bundle.stories.indices) { index in
                        GeometryReader { capsule in
                            let width = capsule.size.width
                            let normalizedProgress = (progress - CGFloat(index))
                                .clamped(to: 0...1)
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.25))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(.white)
                                    .frame(width: width * normalizedProgress, height: 4)
                            } // ZStack
                        } // Geometry
                    } // ForEach
                } // HStack
                .padding(6)
                .opacity(isPressed ? 0 : 1)
                .animation(.easeOut(duration: 0.5), value: isPressed)
            } // ZStack
            .rotation3DEffect(rotationAngle(in: geometry),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: geometry.frame(in: .global).minX > 0 ? .leading : .trailing,
                              perspective: 2.5)
        } // GeometryReader
    }
    
    private func rotationAngle(in geometry: GeometryProxy) -> Angle {
        let progress = geometry.frame(in: .global).minX / geometry.size.width
        return .degrees(45 * progress)
    }
}
