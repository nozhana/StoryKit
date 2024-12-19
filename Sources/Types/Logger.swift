//
//  File.swift
//  StoryKit
//
//  Created by Nozhan Amiri on 12/19/24.
//

import Foundation
import OSLog

protocol Logging {}

extension Logging {
    static private var logger: Logger { .init(subsystem: "com.nozhana.storykit", category: typeName) }
    static private var typeName: String { .init(describing: self) }
    
    func log(_ message: String, level: OSLogType = .default) {
        Self.logger.log(level: level, "\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logInfo(_ message: String) {
        Self.logger.info("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logError(_ message: String) {
        Self.logger.error("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logDebug(_ message: String) {
        Self.logger.debug("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logTrace(_ message: String) {
        Self.logger.trace("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logWarning(_ message: String) {
        Self.logger.warning("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logNotice(_ message: String) {
        Self.logger.notice("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logCritical(_ message: String) {
        Self.logger.critical("\(Self.typeName): \(#function) -> \(message)")
    }
    
    func logFault(_ message: String) {
        Self.logger.fault("\(Self.typeName): \(#function) -> \(message)")
    }
}
