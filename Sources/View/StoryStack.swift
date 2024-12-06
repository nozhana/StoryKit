//
//  StoryStack.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

struct StoryStack: View {
    @EnvironmentObject private var storyModel: StoryViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(storyModel.bundles) { bundle in
                    Image(bundle.profileImage, bundle: .module)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                        .padding(3)
                        .background {
                            if !bundle.isSeen {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(.linearGradient(colors: bundle.isCloseFriend
                                                                     ? [.green, .teal]
                                                                     : [.red, .orange, .red, .orange],
                                                                     startPoint: .bottomLeading,
                                                                     endPoint: .topTrailing))
                            }
                        }
                        .asButton {
                            storyModel.currentBundle = bundle
                            storyModel.showStory.toggle()
                        }
                        .fullScreenCover(isPresented: $storyModel.showStory, content: Story.init)
                } // ForEach
            } // LazyHStack
            .padding()
        } // ScrollView
    }
}

#Preview {
    StoryStackPreviews()
}

private struct StoryStackPreviews: View {
    @StateObject private var storyModel = StoryViewModel.preview
    
    var body: some View {
        StoryStack()
            .environmentObject(storyModel)
    }
}
