//
//  SourceEditorCommand.swift
//  Convert Naming
//
//  Created by aniltaskiran on 26.05.2020.
//  Copyright © 2020 Anıl. All rights reserved.
//

import Foundation
import XcodeKit

class UppercasedCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer { completionHandler(nil) }
        let buffer = invocation.buffer
        
        guard let firstSelection = buffer.selections.firstObject as? XCSourceTextRange,
                  let lastSelection = buffer.selections.lastObject as? XCSourceTextRange else {
                      return
              }
              
        if firstSelection.start.line == lastSelection.end.line {
            if let line = buffer.lines[firstSelection.start.line] as? String {
                let value = line.substring(with: firstSelection.start.column..<lastSelection.end.column)
                buffer.lines[firstSelection.start.line] = line.replacingOccurrences(of: value, with: value.uppercased())
            }
        } else {
            let range = (firstSelection.start.line...lastSelection.end.line).saneRange(for: buffer.lines.count)
            let lines = range.compactMap({ (buffer.lines[$0] as? String)?.uppercased() })

            guard lines.count == range.count else {
                return
            }
            
            let totalLineCount = buffer.lines.count
            range.enumerated().forEach({
                if $1 > totalLineCount { return }
                buffer.lines[$1] = lines[$0]
            })
            let lastSelectedLine = buffer.lines[range.upperBound] as? String
            
            firstSelection.start.column = 0
            lastSelection.end.column = lastSelectedLine?.count ?? 0
        }
    
        completionHandler(nil)
    }
    
}

extension String {
    func index(from: Int) -> Index {
         return self.index(startIndex, offsetBy: from)
     }

     func substring(from: Int) -> String {
         let fromIndex = index(from: from)
         return String(self[fromIndex...])
     }

     func substring(to: Int) -> String {
         let toIndex = index(from: to)
         return String(self[..<toIndex])
     }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
