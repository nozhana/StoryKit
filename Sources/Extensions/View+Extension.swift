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
            Haptic.shared.generate(feedback)
        }
    }
    
    func haptic<T: Equatable>(trigger: T, feedback: @escaping (_ value: T) -> HapticFeedback?) -> some View {
        onChange(of: trigger) { value in
            if let feedback = feedback(value) {
                Haptic.shared.generate(feedback)
            }
        }
    }
    
    func haptic(_ feedback: HapticFeedback, trigger: Bool, onlyTrue: Bool = false) -> some View {
        onChange(of: trigger) { value in
            if !onlyTrue || (onlyTrue && value) {
                Haptic.shared.generate(feedback)
            }
        }
    }
}
