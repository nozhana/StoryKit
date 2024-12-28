//
//  File.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/28/24.
//

import SwiftUICore

extension UnitPoint: @retroactive AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result.x += rhs.x
        result.y += rhs.y
        return result
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result.x -= rhs.x
        result.y -= rhs.y
        return result
    }
}

extension UnitPoint: @retroactive Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.x < rhs.x) && (lhs.y < rhs.y)
    }
}
