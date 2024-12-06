//
//  View+Extension.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/6/24.
//

import SwiftUI

extension View {
    func asButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: { self })
    }
}
