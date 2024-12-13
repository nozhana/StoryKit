//
//  StoryStack.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

public struct StoryStack: View {
    @Binding var bundles: [StoryBundleData]
    @Binding var currentBundle: StoryBundleData
    @Binding var show: Bool
    
    public init(bundles: Binding<[StoryBundleData]>, currentBundle: Binding<StoryBundleData>, show: Binding<Bool>) {
        self._bundles = bundles
        self._currentBundle = currentBundle
        self._show = show
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(bundles) { bundle in
                    Button {
                        currentBundle = bundle
                        show = true
                    } label: {
                        bundle.profileView
                            .frame(width: 50, height: 50)
                            .clipShape(.circle)
                            .padding(3)
                            .background {
                                if !bundle.isSeen {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(
                                            .linearGradient(
                                                colors: bundle.isCloseFriend
                                                ? [.green, .teal]
                                                : [.red, .orange, .red, .orange],
                                                startPoint: .bottomLeading,
                                                endPoint: .topTrailing
                                            )
                                        )
                                }
                            }
                    } // Button/label
                    .fullScreenCover(isPresented: $show) {
                        Story(bundles: $bundles, currentBundle: $currentBundle)
                    }
                } // ForEach
            } // LazyHStack
            .padding()
        } // ScrollView
    }
}
