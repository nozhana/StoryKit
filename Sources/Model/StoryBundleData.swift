//
//  StoryBundleData.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import Foundation

struct StoryBundleData: Identifiable, Hashable {
    let id = UUID()
    var profileName: String
    var profileImage: String
    var isSeen = false
    var isCloseFriend = false
    var stories: [StoryData]
}
