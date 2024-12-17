//
//  Loadable.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/17/24.
//

import Foundation

enum Loadable<Value> {
    case empty
    case loading(Progress)
    case failure(Error)
    case loaded(Value)
    
    var value: Value? {
        if case .loaded(let value) = self {
            value
        } else {
            nil
        }
    }
    
    var isLoaded: Bool {
        value != nil
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            true
        } else {
            false
        }
    }
    
    var progress: Progress? {
        if case .loading(let progress) = self {
            progress
        } else {
            nil
        }
    }
    
    var isLoading: Bool {
        progress != nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            error
        } else {
            nil
        }
    }
    
    var hasError: Bool {
        error != nil
    }
}
