//
//  Comparable+Extension.swift
//  SwiftyStories
//
//  Created by Nozhan Amiri on 12/8/24.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(range.lowerBound, self), range.upperBound)
    }
    
    func between(lhs: Self, rhs: Self) -> Bool {
        lhs <= self && self <= rhs
    }
}

extension Comparable where Self: AdditiveArithmetic {
    func snapped(to values: [Self], tolerance: Self) -> Self {
        for value in values {
            if between(lhs: value - tolerance, rhs: value + tolerance) {
                return value
            }
        }
        return self
    }
}
