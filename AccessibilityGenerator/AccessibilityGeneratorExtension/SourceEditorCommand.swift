//
//  SourceEditorCommand.swift
//  AccessibilityGeneratorExtension
//
//  Created by Aytuğ Sevgi on 5.07.2021.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.lines
        guard var arrayLines = Array(lines) as? Array<String> else { return }
        if let firstImportLine = arrayLines.first { $0.contains("import") },
           let index = arrayLines.firstIndex(of: firstImportLine),
           !arrayLines.contains(where: {$0.contains("import AccessibilityKit")}) {
            arrayLines.insert("import AccessibilityKit", at: abs(index.distance(to: 0)))
        }
        guard let classLine = arrayLines.first(where: { $0.contains("class") && $0.contains(":") }) else { return }
        let classLineWords = classLine.split(separator: " ")
        guard let classIndex = classLineWords.firstIndex(of: "class") else { return }
        var className = String(classLineWords[classIndex + 1])
        let isCellView = className.suffix(5).contains("Cell")
        className.removeAll { $0 == ":"}
        let interfaceName = className.replacingOccurrences(of: "Controller", with: "")
        //MARK: - Protocol conform AccessibilityIdentifiable
        if let interfaceLine = arrayLines.first(where: { $0.contains("protocol \(interfaceName)") }),
           !interfaceLine.contains("AccessibilityIdentifiable") {
            var interfaceLineWords = interfaceLine.split(separator: " ")
            var needComma = false
            let isHasAnyConform = interfaceLineWords.count > 3
            if isHasAnyConform && interfaceLineWords.contains("AnyObject") {
                interfaceLineWords.removeAll { $0 == "AnyObject" }
                
            } else if isHasAnyConform && interfaceLineWords.contains("AnyObject,") {
                interfaceLineWords.removeAll { $0 == "AnyObject," }
                needComma = true
            }
            
            else if !isHasAnyConform {
                interfaceLineWords[1].append(":")
            } else {
                interfaceLineWords[interfaceLineWords.count - 2].append(",")
            }
            if needComma {
                interfaceLineWords[interfaceLineWords.count - 2].append(",")
            }
            interfaceLineWords.insert("AccessibilityIdentifiable", at: interfaceLineWords.count - 1 )
            
            guard let interfaceIndex = arrayLines.firstIndex(of: interfaceLine) else { return }
            arrayLines.remove(at: abs(interfaceIndex.distance(to: 0)))
            arrayLines.insert(interfaceLineWords.joined(separator: " "), at: abs(interfaceIndex.distance(to: 0)))
        }
        //MARK: - Class extension make UITestable
        let outlets = arrayLines.filter { $0.contains("@IBOutlet") }
        let outletNames = outlets.map{ $0.split(separator: " ").first { $0.last == ":" }}
        arrayLines.append("\n// MARK: - UITestable\nextension \(className): UITestablePage {\n")
        arrayLines.append("\ttypealias UIElementType = UIElements.\(className)Elements\n\n")
        arrayLines.append("\tfunc setAccessibilityIdentifiers() {\n")
    
        for name in outletNames {
            guard var name = name else { continue }
            name.removeLast()
            arrayLines.append("\t\tmakeViewTestable(\(name), .\(name))\n")
        }
        arrayLines.append("\t}\n")
        var cellName = className
        if isCellView {
            var firstChar = ""
            for char in cellName {
                if char.isLowercase {
                    break
                }
                firstChar = String(cellName.removeFirst())
            }
            cellName = firstChar.lowercased() + cellName
            arrayLines.append("\n\tfunc setAccessibilityIdentifiers(at index: Int) {\n")
            arrayLines.append("\t\tmakeViewTestable(self, using: .\(cellName), index: index)\n")
            arrayLines.append("\t}\n")
        }
        arrayLines.append("}\n\n")
        arrayLines.append(writeUIElementsExtension(outletNames: outletNames, elementsName: "\(className)Elements", isCell: isCellView, cellName: cellName))
        lines.removeAllObjects()
        lines.addObjects(from: arrayLines)
        completionHandler(nil)
    }
    
    func writeUIElementsExtension(outletNames: [String.SubSequence?], elementsName: String, isCell: Bool, cellName: String) -> String {
        var elementExtension = "public extension UIElements {\n"
        elementExtension.append("\tenum \(elementsName): String, UIElement {\n")
        for name in outletNames {
            guard var name = name else { continue }
            name.removeLast()
            elementExtension.append("\t\tcase \(name)\n")
        }
        if isCell {
            elementExtension.append("\t\tcase \(cellName)\n")
        }
        elementExtension.append("\t}\n}")
        return elementExtension
    }
}
