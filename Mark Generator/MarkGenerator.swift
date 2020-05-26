//
//  MarkGenerator.swift
//  Mark Generator
//
//  Created by aniltaskiran on 24.05.2020.
//  Copyright © 2020 Anıl. All rights reserved.
//

import Foundation
import XcodeKit

class MarkGenerator: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let bridgedLines = invocation.buffer.lines.compactMap { $0 as? String }

        bridgedLines.enumerated().forEach { (line) in
            if line.element.isExtension {
                let index = line.element.contains("private") ? 3 : 2
                let protocolName = line.element.split(separator: " ")[index]
                invocation.buffer.lines[line.offset - 1] = "// MARK: - \(protocolName)"
            }
        }
        completionHandler(nil)
    }
}



extension String {
    var isExtension: Bool {
        contains("extension ")
    }
}
