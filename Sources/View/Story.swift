//
//  Story.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

public struct Story: View {
    var bundles: [StoryBundleData]
    @Binding var currentBundle: StoryBundleData
    
    @State private var isPressed = false
    @State private var yOffset: CGFloat = 0
    @State private var progress: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    public init(bundles: [StoryBundleData], currentBundle: Binding<StoryBundleData>) {
        self.bundles = bundles
        self._currentBundle = currentBundle
    }
    
    private let timer = Timer.publish(every: 0.05, tolerance: 0.01, on: .main, in: .common).autoconnect()
    
    private var currentStoryIndex: Int {
        min(Int(progress), currentBundle.stories.count - 1)
    }
    
    public var body: some View {
        let tapGesture = SpatialTapGesture()
            .onEnded { value in
                progress = CGFloat(min(max(0, currentStoryIndex + (value.location.x > 100 ? 1 : -1)), currentBundle.stories.count))
            }
        
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                yOffset = value.translation.height
                isPressed = true
            }
            .onEnded { value in
                if value.translation.height > 250 {
                    dismiss()
                    return
                }
                withAnimation {
                    yOffset = 0
                    isPressed = false
                }
            }
        
        let combinedGesture = tapGesture.exclusively(before: dragGesture)
        
        ZStack(alignment: .topTrailing) {
            if bundles.isEmpty || currentBundle.isEmpty {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Failed to load story")
                }
                .font(.title2.bold())
                .foregroundStyle(.secondary)
                .onAppear {
                    timer.upstream.connect().cancel()
                }
            } else {
                TabView(selection: $currentBundle) {
                    ForEach(bundles) { bundle in
                        StoryBundle(bundle: bundle, progress: progress, isPressed: isPressed)
                            .tag(bundle)
                    } // ForEach
                } // TabView
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .padding()
                    .opacity(isPressed ? 0 : 1)
                    .animation(.easeOut(duration: 0.5), value: isPressed)
            } // Button/label
            .padding(.top, 16)
        } // ZStack
        .transition(.move(edge: .bottom))
        .offset(y: yOffset)
        .gesture(combinedGesture)
        .onChange(of: currentBundle) { _ in
            progress = 0
        }
        .onReceive(timer) { _ in
            if Int(progress) < currentBundle.stories.count, !isPressed {
                progress += 0.01
            } else {
                let index = min(Int(progress), currentBundle.stories.count - 1)
                let story = currentBundle.stories[index]

                if let lastStory = currentBundle.stories.last,
                   lastStory.id == story.id, !isPressed {
                    
                    if let lastBundle = bundles.last,
                       currentBundle.id == lastBundle.id {
                        dismiss()
                    } else {
                        let bundleIndex = bundles.firstIndex { $0.id == currentBundle.id }!
                        withAnimation(.easeInOut) {
                            currentBundle = bundles[bundleIndex + 1]
                        }
                    }
                }
            }
        } // onReceive
    }
}
