//
//  Haptic.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation
import CoreHaptics
import class UIKit.UIImpactFeedbackGenerator
import class UIKit.UISelectionFeedbackGenerator

final class Haptic: Logging {
    /// Singleton
    static let shared = Haptic()
    
    // MARK: - Properties
    private var engine: CHHapticEngine? {
        didSet {
            guard let engine else { return }
            engine.playsHapticsOnly = true
            engine.isAutoShutdownEnabled = false
            engine.notifyWhenPlayersFinished { _ in
                self.player = nil
                return .leaveEngineRunning
            }
            engine.stoppedHandler = engineDidStop(withReason:)
            engine.resetHandler = engineDidRecoverFromServerError
        }
    }
    
    private var player: CHHapticPatternPlayer?
    
    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    
    // MARK: - Initialization
    private init() {
        do {
            engine = try CHHapticEngine()
        } catch {
            logError("Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Engine
    private func engineDidStop(withReason reason: CHHapticEngine.StoppedReason) {
        logError("reason: \(reason)")
    }
    
    private func engineDidRecoverFromServerError() {
        logWarning("Engine reset.")
        prepare()
    }
    
    // MARK: Engine(Public)
    func prepare() {
        do {
            try engine?.start()
        } catch {
            logError("Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    func stopEngine() {
        engine?.stop { [weak self] error in
            guard let self, let error else { return }
            logWarning("Failed to stop haptic engine: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Haptics
    private func playImpactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle? = nil, intensity: CGFloat? = nil) {
        let generator: UIImpactFeedbackGenerator
        if let style {
            generator = .init(style: style)
        } else {
            generator = .init()
        }
        
        if let intensity {
            generator.impactOccurred(intensity: intensity)
        } else {
            generator.impactOccurred()
        }
    }
    
    private func playSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    private func playAlignmentHaptic(magnitude: Double) {
        guard let engine else { return }
        try? engine.start()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(magnitude))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let attack = CHHapticEventParameter(parameterID: .attackTime, value: 0.4)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, attack], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            self.player = try engine.makePlayer(with: pattern)
            try player!.start(atTime: CHHapticTimeImmediate)
        } catch {
            logError("Failed to play alignment haptic: \(error.localizedDescription)")
        }
    }
    
    private func playWarningHaptic(magnitude: Double, duration: TimeInterval) {
        guard let engine else { return }
        try? engine.start()
        
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: duration, by: 0.1) {
            let value = Float((1 - i / duration) * magnitude.clamped(to: 0...1))
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: value)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: value)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            self.player = try engine.makePlayer(with: pattern)
            try player!.start(atTime: CHHapticTimeImmediate)
        } catch {
            logError("Failed to play warning haptic: \(error.localizedDescription)")
        }
    }
    
    private func playRollAwayHaptic(magnitude: Double, duration: TimeInterval) {
        guard let engine else { return }
        try? engine.start()
        
        var events = [CHHapticEvent]()
        
        var relativeTimeInverse = duration
        
        while relativeTimeInverse > 0.1 {
            let value = (relativeTimeInverse * magnitude).clamped(to: 0...1)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(value))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(value))
            let attack = CHHapticEventParameter(parameterID: .attackTime, value: Float(value / 2))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, attack], relativeTime: duration - relativeTimeInverse)
            events.append(event)
            relativeTimeInverse /= 1.3
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            self.player = try engine.makePlayer(with: pattern)
            try player!.start(atTime: CHHapticTimeImmediate)
        } catch {
            logError("Failed to play roll away haptic: \(error.localizedDescription)")
        }
    }
    
    private func playLevelChangeHaptic(level: Double) {
        guard let engine else { return }
        try? engine.start()
        
        let parameterValue = level.clamped(to: 0...1) * 0.7 + 0.2
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(parameterValue))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(parameterValue))
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            self.player = try engine.makePlayer(with: pattern)
            try player!.start(atTime: CHHapticTimeImmediate)
        } catch {
            logError("Failed to play level change haptic: \(error.localizedDescription)")
        }
    }
    
    func play(_ feedback: Feedback) {
        switch feedback {
        case .impact(let style, let intensity):
            playImpactHaptic(style: style, intensity: intensity)
        case .selection:
            playSelectionHaptic()
        case .alignment(let magnitude):
            playAlignmentHaptic(magnitude: magnitude)
        case .warning(let magnitude, let duration):
            playWarningHaptic(magnitude: magnitude, duration: duration)
        case .rollAway(let magnitude, let duration):
            playRollAwayHaptic(magnitude: magnitude, duration: duration)
        case .levelChange(let level):
            playLevelChangeHaptic(level: level)
        }
    }
}

extension Haptic {
    enum Feedback {
        case impact(style: UIImpactFeedbackGenerator.FeedbackStyle? = nil, intensity: CGFloat? = nil)
        case selection
        case alignment(magnitude: Double = 0.75)
        case warning(magnitude: Double = 1, duration: TimeInterval = 1)
        case rollAway(magnitude: Double = 1, duration: TimeInterval = 1.5)
        case levelChange(level: Double = 0.5)
    }
}
