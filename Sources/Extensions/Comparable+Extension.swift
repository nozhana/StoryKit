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
}
