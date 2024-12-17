//
//  View+Extension.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import SwiftUI

extension View {
    func show(if condition: Bool) -> some View {
        opacity(condition ? 1 : 0)
    }
    
    func haptic<T: Equatable>(_ feedback: HapticFeedback, trigger: T) -> some View {
        onChange(of: trigger) { _ in
            feedback.generate()
        }
    }
    
    func haptic<T: Equatable>(trigger: T, feedback: @escaping (_ value: T) -> HapticFeedback?) -> some View {
        onChange(of: trigger) { value in
            feedback(value)?.generate()
        }
    }
}

enum HapticFeedback {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle? = nil, intensity: CGFloat? = nil)
    case selection
    
    func generate() {
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
        }
    }
}
