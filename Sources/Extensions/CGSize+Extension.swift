//
//  CGSize+Extension.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation
import SwiftUICore

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
    static func * (lhs: Self, rhs: Double) -> Self {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func *= (lhs: inout Self, rhs: Double) {
        lhs = lhs * rhs
    }
    
    static func / (lhs: Self, rhs: Double) -> Self {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    static func /= (lhs: inout Self, rhs: Double) {
        lhs = lhs / rhs
    }
    
    static func * (lhs: Self, rhs: UnitPoint) -> CGPoint {
        CGPoint(x: lhs.width * rhs.x, y: lhs.height * rhs.y)
    }
}

extension CGSize: @retroactive Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }
}

extension CGSize {
    var absolute: CGSize {
        CGSize(width: abs(width), height: abs(height))
    }
}

extension CGSize {
    func toUnitPoint() -> UnitPoint {
        UnitPoint(x: width, y: height)
    }
}
