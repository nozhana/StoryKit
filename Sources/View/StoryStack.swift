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
    var postStory: Bool
    var myProfileName: String
    var myProfileImage: AnyView
    
    @State private var showEditor = false
    
    public init<ProfileImage: View>(bundles: Binding<[StoryBundleData]>, currentBundle: Binding<StoryBundleData>, show: Binding<Bool>, postStory: Bool = false, myProfileName: String = "Me", myProfileImage: @escaping () -> ProfileImage) {
        self._bundles = bundles
        self._currentBundle = currentBundle
        self._show = show
        self.postStory = postStory
        self.myProfileName = myProfileName
        self.myProfileImage = AnyView(myProfileImage())
    }
    
    public init(bundles: Binding<[StoryBundleData]>, currentBundle: Binding<StoryBundleData>, show: Binding<Bool>, postStory: Bool = false, myProfileName: String = "Me") {
        self._bundles = bundles
        self._currentBundle = currentBundle
        self._show = show
        self.postStory = postStory
        self.myProfileName = myProfileName
        if let myBundle = bundles.wrappedValue.first(where: { $0.profileName == myProfileName }) {
            self.myProfileImage = myBundle.profileView
        } else {
            self.myProfileImage = AnyView(Image(systemName: "person.bust.fill")
                .bold()
                .imageScale(.large)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.linearGradient(colors: [.red, .orange, .red], startPoint: .bottomLeading, endPoint: .topTrailing))
            )
        }
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                if postStory {
                    Button {
                        showEditor = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            myProfileImage
                                .frame(width: 50, height: 50)
                                .clipShape(.circle)
                                .padding(3)
                            
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .foregroundStyle(.blue)
                                .frame(width: 20, height: 20)
                                .background(.white, in: .circle)
                                .padding(3)
                                .offset(x: 3, y: 3)
                        } // ZStack
                    } // Button/label
                    .buttonStyle(.storyStack)
                    .fullScreenCover(isPresented: $showEditor) {
                        StoryEditor { image in
                            let newStory = StoryData(label: Image(uiImage: image))
                            if let myBundleIndex = bundles.firstIndex(where: { $0.profileName == myProfileName }) {
                                bundles[myBundleIndex].stories.append(newStory)
                                bundles[myBundleIndex].isSeen = false
                            } else {
                                let bundle = StoryBundleData(profileName: myProfileName, profileView: myProfileImage, stories: [newStory])
                                bundles.insert(bundle, at: 0)
                            }
                        }
                    }
                }
                
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
                    .buttonStyle(.storyStack)
                    .fullScreenCover(isPresented: $show) {
                        Story(bundles: $bundles, currentBundle: $currentBundle)
                    }
                } // ForEach
            } // LazyHStack
            .padding()
        } // ScrollView
    }
}
