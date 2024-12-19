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
                model.isDraggingSlowly = value.velocity < .init(width: 20, height: 20)
                let unit = value.location.unit(in: model.canvasSize)
                model.locationUnit.x = unit.x.snapped(to: model.unitXSnaps, tolerance: 0.02)
                model.locationUnit.y = unit.y.snapped(to: model.unitYSnaps, tolerance: 0.02)
            }
            .onEnded { _ in
                model.isDragging = false
                model.isDraggingSlowly = false
                if model.isInDeleteArea {
                    withAnimation {
                        model.imageState = .empty
                    }
                    model.locationUnit = .center
                    Haptic.shared.generate(.rollAway())
                }
            }
        
        let magnifyGesture = MagnificationGesture()
            .onChanged { value in
                model.scale = (model.lastScale * value)
                    .snapped(to: model.scaleSnaps, tolerance: 0.1)
                    .clamped(to: 0.25...5)
            }
            .onEnded { value in
                model.lastScale = (model.lastScale * value)
                    .snapped(to: model.scaleSnaps, tolerance: 0.1)
                    .clamped(to: 0.25...5)
            }
        
        let rotationGesture = RotationGesture()
            .onChanged { angle in
                model.rotation = (model.lastRotation + angle.degrees)
                    .snapped(to: model.rotationSnaps, tolerance: 5)
            }
            .onEnded { angle in
                model.lastRotation = (model.lastRotation + angle.degrees)
                    .snapped(to: model.rotationSnaps, tolerance: 5)
            }
        
        let combinedGesture = dragGesture.simultaneously(with: rotationGesture).simultaneously(with: magnifyGesture)
        
        ZStack {
            Color.black
            
            Group {
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: .infinity)
                    .opacity(model.snappedToVerticalCenter ? 1 : 0)
                    .foregroundStyle(.blue)
                    .animation(.easeOut, value: model.snappedToVerticalCenter)
                    .haptic(.alignment(), trigger: model.snappedToVerticalCenter, onlyTrue: true)
                
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: .infinity)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(model.leadingGuideOpacity)
                    .foregroundStyle(model.snappedToLeading ? .blue : .white)
                    .animation(.easeOut, value: model.snappedToLeading)
                    .haptic(.alignment(), trigger: model.snappedToLeading, onlyTrue: true)
                
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: .infinity)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(model.trailingGuideOpacity)
                    .foregroundStyle(model.snappedToTrailing ? .blue : .white)
                    .animation(.easeOut, value: model.snappedToTrailing)
                    .haptic(.alignment(), trigger: model.snappedToTrailing, onlyTrue: true)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .opacity(model.snappedToHorizontalCenter ? 1 : 0)
                    .foregroundStyle(.blue)
                    .animation(.easeOut, value: model.snappedToHorizontalCenter)
                    .haptic(.alignment(), trigger: model.snappedToHorizontalCenter, onlyTrue: true)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .opacity(model.topGuideOpacity)
                    .foregroundStyle(model.snappedToTop ? .blue : .white)
                    .animation(.easeOut, value: model.snappedToTop)
                    .haptic(.alignment(), trigger: model.snappedToTop, onlyTrue: true)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .opacity(model.bottomGuideOpacity)
                    .foregroundStyle(model.snappedToBottom ? .blue : .white)
                    .animation(.easeOut, value: model.snappedToBottom)
                    .haptic(.alignment(), trigger: model.snappedToBottom, onlyTrue: true)
            } // Group
            
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
                    GeometryReader { canvas in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .transition(.scale)
                            .rotationEffect(.degrees(model.rotation))
                            .haptic(.alignment(), trigger: model.snappedRotation, onlyTrue: true)
                            .scaleEffect(model.isInDeleteArea ? 0.15 : model.scale)
                            .animation(.easeOut(duration: 0.25), value: model.isInDeleteArea)
                            .haptic(.alignment(), trigger: model.snappedScale, onlyTrue: true)
                            .position(model.location)
                            .gesture(combinedGesture)
                            .onAppear {
                                model.canvasSize = canvas.size
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
                        model.isSnappingLocation.toggle()
                    } label: {
                        Image(systemName: model.isSnappingLocation ? "pin.circle.fill" : "pin.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundStyle(model.isSnappingLocation ? .yellow : .white)
                    } // Button/label
                    
                    Button {
                        model.isSnappingScale.toggle()
                    } label: {
                        Image(systemName: model.isSnappingScale ? "arrowshape.left.arrowshape.right.fill" : "arrowshape.left.arrowshape.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundStyle(model.isSnappingScale ? .yellow : .white)
                    } // Button/label
                    
                    Button {
                        model.isSnappingRotation.toggle()
                    } label: {
                        Image(systemName: model.isSnappingRotation ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundStyle(model.isSnappingRotation ? .yellow : .white)
                    } // Button/label
                    
                    Button {
                        model.controlsSide.toggle()
                    } label: {
                        Image(systemName: model.controlsSide == .trailing ? "align.horizontal.right.fill" : "align.horizontal.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .foregroundStyle(.white)
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
                .haptic(.impact(style: .heavy, intensity: 0.9), trigger: model.isInDeleteArea, onlyTrue: true)
            
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
        .clipShape(.rect(cornerRadius: 12))
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
        @Published var isSnappingLocation = true
        @Published var isSnappingRotation = true
        @Published var isSnappingScale = true
        @Published var isDragging = false
        @Published var isDraggingSlowly = false
        @Published var imageRatio: CGFloat = 1
        @Published var canvasSize: CGSize = .zero
        @Published var renderSize: CGSize = .zero
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
        
        private var imageDragUnit: CGSize {
            let imageDragBounds = canvasSize - imageSize
            return imageDragBounds / canvasSize
        }
        
        private var leadingGuide: CGFloat {
            0.5 - imageDragUnit.width / 2
        }
        
        private var trailingGuide: CGFloat {
            0.5 + imageDragUnit.width / 2
        }
        
        private var topGuide: CGFloat {
            0.5 - imageDragUnit.height / 2
        }
        
        private var bottomGuide: CGFloat {
            0.5 + imageDragUnit.height / 2
        }
        
        var unitXSnaps: [CGFloat] {
            guard isSnappingLocation, isDraggingSlowly else { return [] }
            return [
                leadingGuide,
                0.5,
                trailingGuide
            ]
        }
        
        var unitYSnaps: [CGFloat] {
            guard isSnappingLocation, isDraggingSlowly else { return [] }
            return [
                topGuide,
                0.5,
                bottomGuide
            ]
        }
        
        var snappedToVerticalCenter: Bool {
            locationUnit.x == 0.5 && isDraggingSlowly && isSnappingLocation
        }
        
        var snappedToLeading: Bool {
            locationUnit.x == leadingGuide && isDraggingSlowly && isSnappingLocation
        }
        
        var leadingGuideOpacity: CGFloat {
            guard isSnappingLocation, isDragging else { return 0 }
            let distance = abs(locationUnit.x - leadingGuide)
            let step = simd_smoothstep(0, 0.2, distance)
            return 1 - step
        }
        
        var snappedToTrailing: Bool {
            locationUnit.x == trailingGuide && isDraggingSlowly && isSnappingLocation
        }
        
        var trailingGuideOpacity: CGFloat {
            guard isSnappingLocation, isDragging else { return 0 }
            let distance = abs(locationUnit.x - trailingGuide)
            let step = simd_smoothstep(0, 0.2, distance)
            return 1 - step
        }
        
        var snappedToHorizontalCenter: Bool {
            locationUnit.y == 0.5 && isDraggingSlowly && isSnappingLocation
        }
        
        var snappedToTop: Bool {
            locationUnit.y == topGuide && isDraggingSlowly && isSnappingLocation
        }
        
        var topGuideOpacity: CGFloat {
            guard isSnappingLocation, isDragging else { return 0 }
            let distance = abs(locationUnit.y - topGuide)
            let step = simd_smoothstep(0, 0.2, distance)
            return 1 - step
        }
        
        var snappedToBottom: Bool {
            locationUnit.y == bottomGuide && isDraggingSlowly && isSnappingLocation
        }
        
        var bottomGuideOpacity: CGFloat {
            guard isSnappingLocation, isDragging else { return 0 }
            let distance = abs(locationUnit.y - bottomGuide)
            let step = simd_smoothstep(0, 0.2, distance)
            return 1 - step
        }
        
        var rotationSnaps: [CGFloat] {
            guard isSnappingRotation else { return [] }
            return (0...24)
                .flatMap { [$0, -$0] }
                .map { CGFloat($0) * 15 }
        }
        
        var snappedRotation: Bool {
            guard isSnappingRotation else { return false }
            return rotationSnaps.contains(rotation)
        }
        
        var scaleSnaps: [CGFloat] {
            guard isSnappingScale else { return [] }
            return (1...4)
                .map { CGFloat($0) * 0.5 }
        }
        
        var snappedScale: Bool {
            guard isSnappingScale else { return false }
            return scaleSnaps.contains(scale)
        }
        
        var isInDeleteArea: Bool {
            locationUnit.x.between(lhs: 0.45, rhs: 0.55) && locationUnit.y > 0.85
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
