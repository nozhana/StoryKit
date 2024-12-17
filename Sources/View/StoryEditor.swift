//
//  StoryEditor.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/16/24.
//

import SwiftUI
import PhotosUI

public struct StoryEditor: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = Observed()
    var onPosted: (UIImage) -> Void
    
    public init(onPosted: @escaping (UIImage) -> Void) {
        self.onPosted = onPosted
    }
    
    public var body: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                model.isDragging = true
                let unit = value.location.unit(in: model.canvasSize)
                model.locationUnit.x = unit.x.snapped(to: model.unitXSnaps, tolerance: 0.03)
                model.locationUnit.y = unit.y.snapped(to: model.unitYSnaps, tolerance: 0.03)
            }
            .onEnded { _ in
                model.isDragging = false
                if model.isInDeleteArea {
                    withAnimation {
                        model.imageState = .empty
                    }
                    model.locationUnit = .center
                    HapticFeedback.impact(style: .rigid).generate()
                }
            }
        
        let magnifyGesture = MagnificationGesture()
            .onChanged { value in
                model.scale = (model.lastScale * value).snapped(to: [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5], tolerance: 0.1)
            }
            .onEnded { value in
                model.lastScale *= value
            }
        
        let rotationGesture = RotationGesture()
            .onChanged { angle in
                model.rotation = (model.lastRotation + angle.degrees)
                    .snapped(to: (0...8)
                        .map { Double($0) * 45 }
                        .flatMap { [$0, -$0] },
                             tolerance: 5)
            }
            .onEnded { angle in
                model.lastRotation += angle.degrees
            }
        
        let combinedGesture = dragGesture.simultaneously(with: rotationGesture).simultaneously(with: magnifyGesture)
        
        ZStack {
            Color.black
                .clipShape(.rect(cornerRadius: 12))
            
            Group {
                Group {
                    Rectangle()
                        .frame(maxWidth: 1, maxHeight: .infinity)
                        .show(if: model.snappedToVerticalCenter)
                        .animation(.easeOut, value: model.snappedToVerticalCenter)
                    
                    Rectangle()
                        .frame(maxWidth: 1, maxHeight: .infinity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .show(if: model.snappedToLeading)
                        .animation(.easeOut, value: model.snappedToLeading)
                    
                    Rectangle()
                        .frame(maxWidth: 1, maxHeight: .infinity)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .show(if: model.snappedToTrailing)
                        .animation(.easeOut, value: model.snappedToTrailing)
                } // Group
                .foregroundStyle(.linearGradient(colors: [.blue, .teal], startPoint: .top, endPoint: .bottom))
                
                Group {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .show(if: model.snappedToHorizontalCenter)
                        .animation(.easeOut, value: model.snappedToHorizontalCenter)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .show(if: model.snappedToTop)
                        .animation(.easeOut, value: model.snappedToTop)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .show(if: model.snappedToBottom)
                        .animation(.easeOut, value: model.snappedToBottom)
                } // Group
                .foregroundStyle(.linearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing))
            } // Group
            .haptic(trigger: model.snapped) { value in
                value ? .selection : nil
            }
            
            Group {
                switch model.imageState {
                case .empty:
                    Label("Choose an Image", systemImage: "plus.square.dashed")
                        .foregroundStyle(.gray)
                case .loading(let progress):
                    ProgressView("Please wait...", value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                        .progressViewStyle(.circular)
                        .tint(.gray)
                        .foregroundStyle(.gray)
                case .failure(let error):
                    VStack {
                        Label("Failed to load image!", systemImage: "exclamationmark.square.fill")
                            .foregroundStyle(.red)
                        Text(error.localizedDescription)
                            .font(.body)
                    }
                case .loaded(let image):
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .blur(radius: model.isInDeleteArea ? 24 : 0)
                            .animation(.easeOut(duration: 0.25), value: model.isInDeleteArea)
                            .transition(.scale)
                            .rotationEffect(.degrees(model.rotation))
                            .scaleEffect(model.scale)
                            .position(model.location)
                            .gesture(combinedGesture)
                            .onAppear {
                                model.canvasSize = geometry.size
                                model.imageRatio = image.size.width / image.size.height
                            }
                    } // GeometryReader
                } // switch
            } // Group
            .labelStyle(.titleAndIconVertical)
            .font(.system(size: 24, weight: .medium))
            
            if model.imageState.isLoaded {
                VStack {
                    Button {
                        model.isSnapping.toggle()
                    } label: {
                        Image(systemName: model.isSnapping ? "bolt.circle.fill" : "bolt.circle")
                            .resizable()
                            .foregroundStyle(model.isSnapping ? .yellow : .white)
                            .frame(width: 24, height: 24)
                            .padding(8)
                    } // Button/label
                    
                    Button {
                        model.controlsSide.toggle()
                    } label: {
                        Image(systemName: model.controlsSide == .trailing ? "align.horizontal.right.fill" : "align.horizontal.left.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .padding(8)
                    } // Button/label
                } // VStack
                .padding(8)
                .background(.thinMaterial, in: .capsule)
                .frame(maxWidth: .infinity, alignment: model.controlsSide.alignment)
                .animation(.snappy, value: model.controlsSide)
            }
            
            Image(systemName: "trash.circle.fill")
                .resizable()
                .imageScale(.large)
                .foregroundStyle(.red)
                .frame(width: 44, height: 44)
                .padding(4)
                .background(.white, in: .circle)
                .shadow(color: .red.opacity(0.2), radius: 10)
                .scaleEffect(model.isInDeleteArea ? 1 : 0.1)
                .show(if: model.isInDeleteArea)
                .animation(.easeOut(duration: 0.25), value: model.isInDeleteArea)
                .offset(y: 240)
            
            Image(systemName: "xmark")
                .imageScale(.large)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .onTapGesture {
                    dismiss()
                }
            
            Group {
                if model.imageState.isEmpty || model.imageState.hasError {
                    PhotosPicker(selection: $model.selection, matching: .images, photoLibrary: .shared()) {
                        Label("Choose Image", systemImage: "plus.square.dashed")
                    }
                } else if model.imageState.isLoaded {
                    Button("Post Story", systemImage: "arrow.up.forward.app.fill") {
                        if let rendered = model.renderImage() {
                            onPosted(rendered)
                            dismiss()
                        }
                    }
                    .tint(.green)
                }
            } // Group
            .buttonStyle(.capsule)
            .font(.system(size: 18, weight: .bold))
            .padding()
            .frame(maxHeight: .infinity, alignment: .bottom)
        } // ZStack
    }
}

private extension StoryEditor {
    enum ControlsSide {
        case leading, trailing
        
        mutating func toggle() {
            switch self {
            case .leading:
                self = .trailing
            case .trailing:
                self = .leading
            }
        }
        
        var alignment: Alignment {
            switch self {
            case .leading:
                    .leading
            case .trailing:
                    .trailing
            }
        }
    }
    
    final class Observed: ObservableObject {
        @Published var imageState = Loadable<UIImage>.empty {
            didSet {
                switch imageState {
                case .empty, .failure:
                    selection = nil
                default:
                    break
                }
            }
        }
        @Published var selection: PhotosPickerItem? {
            didSet {
                if let selection {
                    let progress = loadTransferable(from: selection)
                    DispatchQueue.main.async {
                        self.imageState = .loading(progress)
                    }
                }
            }
        }
        
        @Published var controlsSide: ControlsSide = .trailing
        @Published var isSnapping = true
        @Published var isDragging = false
        @Published var imageRatio: CGFloat = 1
        @Published var canvasSize: CGSize = .zero
        @Published var locationUnit: UnitPoint = .center
        @Published var lastScale: CGFloat = 0.8
        @Published var scale: CGFloat = 0.8
        @Published var lastRotation: CGFloat = .zero
        @Published var rotation: CGFloat = .zero
        
        var location: CGPoint {
            canvasSize * locationUnit
        }
        
        var imageSize: CGSize {
            CGSize(width: canvasSize.width, height: canvasSize.width / imageRatio) * scale
        }
        
        var unitXSnaps: [CGFloat] {
            guard isSnapping else { return [] }
            let imageDragBounds = canvasSize - imageSize
            let imageDragUnit = imageDragBounds / canvasSize
            return [
                0.5 - imageDragUnit.width / 2,
                0.5,
                0.5 + imageDragUnit.width / 2
            ]
        }
        
        var unitYSnaps: [CGFloat] {
            guard isSnapping else { return [] }
            let imageDragBounds = canvasSize - imageSize
            let imageDragUnit = imageDragBounds / canvasSize
            return [
                0.5 - imageDragUnit.height / 2,
                0.5,
                0.5 + imageDragUnit.height / 2
            ]
        }
        
        var snappedToVerticalCenter: Bool {
            locationUnit.x == 0.5 && isDragging
        }
        
        var snappedToLeading: Bool {
            locationUnit.x == unitXSnaps.first && isDragging
        }
        
        var snappedToTrailing: Bool {
            locationUnit.x == unitXSnaps.last && isDragging
        }
        
        var snappedToHorizontalCenter: Bool {
            locationUnit.y == 0.5 && isDragging
        }
        
        var snappedToTop: Bool {
            locationUnit.y == unitYSnaps.first && isDragging
        }
        
        var snappedToBottom: Bool {
            locationUnit.y == unitYSnaps.last && isDragging
        }
        
        var snapped: Bool {
            snappedToVerticalCenter || snappedToLeading || snappedToTrailing || snappedToHorizontalCenter || snappedToTop || snappedToBottom
        }
        
        var isInDeleteArea: Bool {
            locationUnit.x.between(lhs: 0.45, rhs: 0.55) && locationUnit.y.between(lhs: 0.9, rhs: 1)
        }
        
        @MainActor func renderImage() -> UIImage? {
            guard case .loaded(let image) = imageState else { return nil }
            
            let viewToRender = Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .position(location)
                .frame(width: canvasSize.width, height: canvasSize.height)
            
            let renderer = ImageRenderer(content: viewToRender)
            return renderer.uiImage
        }
        
        private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
            imageSelection.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data?):
                    guard let uiImage = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.imageState = .empty
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        withAnimation {
                            self.imageState = .loaded(uiImage)
                        }
                    }
                case .success(nil):
                    DispatchQueue.main.async {
                        withAnimation {
                            self.imageState = .empty
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        withAnimation {
                            self.imageState = .failure(error)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StoryEditor { uiImage in
        print("posted UIImage: \(uiImage.description)")
    }
}
