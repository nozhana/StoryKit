//
//  StoryViewModel.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUICore

final class StoryViewModel: ObservableObject {
    @Published var bundles: [StoryBundleData] = []
    @Published var currentBundle: StoryBundleData?
    @Published var showStory = false
}


extension StoryViewModel {
    @MainActor static let preview = {
        let model = StoryViewModel()
        model.bundles = [
            StoryBundleData(profileName: "nozhana", profileImage: "profile1", stories: [
                StoryData(image: "story1-1"),
                StoryData(image: "story1-2")
            ]),
            StoryBundleData(profileName: "daddyArta", profileImage: "profile2", isCloseFriend: true, stories: [
                StoryData(image: "story2-1")
            ])
        ]
        return model
    }()
}
