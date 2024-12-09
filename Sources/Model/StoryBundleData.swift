//
//  StoryBundleData.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUICore

public struct StoryBundleData: Identifiable, Hashable {
    public let id = UUID()
    public var profileName: String
    public var profileView: AnyView
    public var isSeen = false
    public var isCloseFriend = false
    public var stories: [StoryData]
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public init(profileName: String, profileImage: String, isSeen: Bool = false, isCloseFriend: Bool = false, stories: [StoryData]) {
        self.profileName = profileName
        self.profileView = AnyView(
            Image(profileImage)
                .resizable()
                .scaledToFill()
        )
        self.isSeen = isSeen
        self.isCloseFriend = isCloseFriend
        self.stories = stories
    }
    
    public init(profileName: String, profileSystemImage: String, isSeen: Bool = false, isCloseFriend: Bool = false, stories: [StoryData]) {
        self.profileName = profileName
        self.profileView = AnyView(
            Image(systemName: profileSystemImage)
                .bold()
                .imageScale(.large)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(colors: [.red, .orange, .red], startPoint: .bottomLeading, endPoint: .topTrailing))
        )
        self.isSeen = isSeen
        self.isCloseFriend = isCloseFriend
        self.stories = stories
    }
    
    public init(profileName: String, profileView: some View, isSeen: Bool = false, isCloseFriend: Bool = false, stories: [StoryData]) {
        self.profileName = profileName
        self.profileView = AnyView(profileView.scaledToFill())
        self.isSeen = isSeen
        self.isCloseFriend = isCloseFriend
        self.stories = stories
    }
    
    public init(profileName: String, isSeen: Bool = false, isCloseFriend: Bool = false, stories: [StoryData], profileView: @escaping () -> some View) {
        self.profileName = profileName
        self.profileView = AnyView(profileView().scaledToFill())
        self.isSeen = isSeen
        self.isCloseFriend = isCloseFriend
        self.stories = stories
    }
    
    public static var empty: StoryBundleData {
        .init(profileName: "", profileView: EmptyView(), stories: [])
    }
    
    var isEmpty: Bool {
        profileName.isEmpty || stories.isEmpty
    }
}
