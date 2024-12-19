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
    
    func haptic<T: Equatable>(_ feedback: Haptic.Feedback, trigger: T) -> some View {
        onChange(of: trigger) { _ in
            Haptic.shared.generate(feedback)
        }
    }
    
    func haptic<T: Equatable>(trigger: T, feedback: @escaping (_ value: T) -> Haptic.Feedback?) -> some View {
        onChange(of: trigger) { value in
            if let feedback = feedback(value) {
                Haptic.shared.generate(feedback)
            }
        }
    }
    
    func haptic<T: Equatable>(_ feedback: Haptic.Feedback, trigger: T, condition: @escaping (T) -> Bool) -> some View {
        onChange(of: trigger) { value in
            if condition(value) {
                Haptic.shared.generate(feedback)
            }
        }
    }
    
    func haptic(_ feedback: Haptic.Feedback, trigger: Bool, onlyTrue: Bool = false) -> some View {
        haptic(feedback, trigger: trigger) { !onlyTrue || $0 }
    }
}
