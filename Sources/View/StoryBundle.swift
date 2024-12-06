//
//  StoryBundle.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/7/24.
//

import SwiftUI

struct StoryBundle: View {
    var bundle: StoryBundleData
    
    var body: some View {
        GeometryReader { geometry in
            Image(bundle.stories[0].image, bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

#Preview {
    StoryBundle(bundle: StoryViewModel.preview.bundles.first!)
}
