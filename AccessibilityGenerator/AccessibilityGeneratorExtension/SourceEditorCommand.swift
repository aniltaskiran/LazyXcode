//
//  SourceEditorCommand.swift
//  AccessibilityGeneratorExtension
//
//  Created by Aytuğ Sevgi on 5.07.2021.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    enum CommandType: String {
        case dev = "fordev"
        case qa = "forqa"
    }
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let manager = AccessibilityGeneratorManager.shared
        manager.lines = invocation.buffer.lines
        if CommandType.init(rawValue: invocation.commandIdentifier) == .qa {
            manager
                .conformAccessiblityIdenfiableToView()?
                .conformUITestablePageToView()?
                .generateUIElementClass()
        } else {
            manager
                .conformAccessiblityIdenfiableToView()?
                .conformUITestablePageToView()
        }
        completionHandler(nil)
    }
}
