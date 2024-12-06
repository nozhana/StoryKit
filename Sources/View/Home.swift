//
//  Home.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject private var storyModel: StoryViewModel
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                StoryStack()
            } // ScrollView
            .navigationTitle("Stories")
        } // NavigationView
    }
}

#Preview {
    HomePreviews()
}

private struct HomePreviews: View {
    @StateObject private var storyModel = StoryViewModel.preview
    
    var body: some View {
        Home()
            .environmentObject(storyModel)
    }
}
