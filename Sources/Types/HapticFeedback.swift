//
//  HapticFeedback.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation
import class UIKit.UIImpactFeedbackGenerator
import class UIKit.UISelectionFeedbackGenerator
import CoreHaptics

enum HapticFeedback {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle? = nil, intensity: CGFloat? = nil)
    case selection
    case warning(magnitude: CGFloat = 1, duration: TimeInterval = 1)
    
    func generate(withEngine engine: CHHapticEngine) {
        switch self {
        case .impact(let style, let intensity):
            let haptic: UIImpactFeedbackGenerator
            if let style {
                haptic = UIImpactFeedbackGenerator(style: style)
            } else {
                haptic = UIImpactFeedbackGenerator()
            }
            
            if let intensity {
                haptic.impactOccurred(intensity: intensity)
            } else {
                haptic.impactOccurred()
            }
        case .selection:
            let haptic = UISelectionFeedbackGenerator()
            haptic.selectionChanged()
        case .warning(let magnitude, let duration):
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            var events = [CHHapticEvent]()
            
            for i in stride(from: 0, to: duration, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float((1 - i / duration) * magnitude.clamped(to: 0...1)))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float((1 - i / duration) * magnitude.clamped(to: 0...1)))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                print("Failed to play warning haptic: \(error.localizedDescription)")
            }
        }
    }
}
