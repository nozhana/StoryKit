//
//  Haptic.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation
import CoreHaptics

struct Haptic {
    static let shared = Haptic()
    
    private init() {
        do {
            try engine?.start()
        } catch {
            print("Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    private let engine = try? CHHapticEngine()
    
    func generate(_ feedback: HapticFeedback) {
        guard let engine else { return }
        feedback.generate(withEngine: engine)
    }
}
