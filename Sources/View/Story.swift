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
    
    @State private var progress: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    public init(bundles: [StoryBundleData], currentBundle: Binding<StoryBundleData>) {
        self.bundles = bundles
        self._currentBundle = currentBundle
    }
    
    @State private var yOffset: CGFloat = 0
    @State private var isPressed = false
    
    private let timer = Timer.publish(every: 0.05, tolerance: 0.01, on: .main, in: .common).autoconnect()
    
    private var currentStoryIndex: Int {
        min(Int(progress), currentBundle.stories.count - 1)
    }
    
    public var body: some View {
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
                .onTapGesture { point in
                    progress = CGFloat(max(0, currentStoryIndex + (point.x > 100 ? 1 : -1)))
                }
                .onLongPressGesture {} onPressingChanged: { pressed in
                    isPressed = pressed
                }
                .onChange(of: currentBundle) { _ in
                    progress = 0
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .transition(.move(edge: .bottom))
                .offset(y: yOffset)
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    yOffset = value.translation.height
                }
                .onEnded { value in
                    withAnimation(.easeOut(duration: 0.5)) {
                        yOffset = 0
                    }
                    
                    if value.translation.height > 250 {
                        dismiss()
                    }
                }
        ) // gesture
        .onReceive(timer) { _ in
            if Int(progress) < currentBundle.stories.count, !isPressed {
                progress += 0.01
            } else {
                let index = min(Int(progress), currentBundle.stories.count - 1)
                let story = currentBundle.stories[index]

                if let lastStory = currentBundle.stories.last,
                   lastStory.id == story.id {
                    
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
