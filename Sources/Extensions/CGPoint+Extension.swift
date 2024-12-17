//
//  CGPoint+Extension.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation
import SwiftUICore

extension CGPoint {
    func unit(in size: CGSize) -> UnitPoint {
        UnitPoint(x: x / size.width, y: y / size.height)
    }
}
