//
//  Story.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

struct Story: View {
    @EnvironmentObject private var storyModel: StoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .clipShape(.rect(cornerRadius: 8))
            
            TabView(selection: $storyModel.currentBundle) {
                ForEach(storyModel.bundles) { bundle in
                    StoryBundle(bundle: bundle)
                        .tag(bundle)
                } // ForEach
            } // TabView
            .tabViewStyle(.page(indexDisplayMode: .never))
            .transition(.move(edge: .bottom))
            
            HStack {
                Image(storyModel.currentBundle?.profileImage ?? "", bundle: .module)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(.circle)
                
                Text("@\(storyModel.currentBundle?.profileName ?? "")")
                    .bold()
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .padding()
                    .asButton(action: dismiss.callAsFunction)
            } // HStack
            .padding()
        } // ZStack
        .offset(y: yOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    yOffset = value.translation.height
                }
                .onEnded { value in
                    if yOffset > 250 {
                        dismiss()
                    } else {
                        withAnimation(.easeOut(duration: 0.5)) {
                            yOffset = 0
                        }
                    }
                }
        )
    }
}

#Preview {
    StoryPreviews()
}

private struct StoryPreviews: View {
    @StateObject private var storyModel = StoryViewModel.preview
    
    init() {
        storyModel.currentBundle = storyModel.bundles.first
    }
    
    var body: some View {
        Story()
            .environmentObject(storyModel)
    }
}
