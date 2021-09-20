//
//  AccessibilityGeneratorManager.swift
//  AccessibilityGenerator
//
//  Created by Aytuğ Sevgi on 16.09.2021.
//

import Foundation

public final class AccessibilityGenerator: Generatable {
    public func isSatisfied(identifier: String) -> Bool {
        identifier == "fordev"
    }

    public func execute(lines: NSMutableArray?) {
        self.lines = lines
        conformAccessiblityIdenfiableToView()?.conformUITestablePageToView()
    }

    public var lines: NSMutableArray?
    private var className: String = .init()
    private var isCellView: Bool {
        className.suffix(5).contains("Cell")
    }

    private lazy var outletNames: [String.SubSequence] = {
        outlets.compactMap { $0.name }
    }()

    private lazy var outletTypes: [String.SubSequence] = {
        outlets.compactMap { $0.type }
    }()

    private lazy var outlets: [(name: String.SubSequence, type: String.SubSequence)] = {
        guard let lines = lines,
              var arrayLines = Array(lines) as? Array<String> else { return .init() }
        let outlets = arrayLines.filter { $0.contains("@IBOutlet") }.compactMap { line -> (String.SubSequence, String.SubSequence)? in
            guard let outlet = line.split(separator: " ").first(where: { $0.last == ":" })?.dropLast(),
                  let type = line.split(separator: " ").last?.dropLast(2),
                  type != "NSLayoutConstraint" else { return nil }
            return (outlet, type)
        }
        return outlets
    }()

    public static var shared : AccessibilityGenerator { AccessibilityGenerator() }

    private func updateLines(from newLines: [String]) {
        guard let lines = lines else { return }
        lines.removeAllObjects()
        lines.addObjects(from: newLines)
    }

    private func addAccessibilityIdetifiable(to conformableLine: String) -> String {
        var conformableLineWords = conformableLine.split(separator: " ")
        var needComma = false
        let isHasAnyConform = conformableLineWords.count > 3
        if isHasAnyConform && conformableLineWords.contains("AnyObject") {
            conformableLineWords.removeAll { $0 == "AnyObject" }

        } else if isHasAnyConform && conformableLineWords.contains("AnyObject,") {
            conformableLineWords.removeAll { $0 == "AnyObject," }
            needComma = true
        }

        else if !isHasAnyConform {
            conformableLineWords[1].append(":")
        } else {
            conformableLineWords[conformableLineWords.count - 2].append(",")
        }
        if needComma {
            conformableLineWords[conformableLineWords.count - 2].append(",")
        }
        conformableLineWords.insert("AccessibilityIdentifiable", at: conformableLineWords.count - 1 )
        return conformableLineWords.joined(separator: " ")
    }

    private func createUIElements(outletNames: [String.SubSequence?], elementsName: String, isCell: Bool, cellName: String) -> String {
        var elementExtension = "public extension UIElements {\n"
        elementExtension.append("\tenum \(elementsName): String, UIElement {\n")
        elementExtension.append("\t\t// MARK: - \(className)\n")
        for (name, type) in outlets {
            elementExtension.append("\t\tcase \(name)\n")
            if type == "UISearchBar" {
                elementExtension.append("\t\tcase searchTextField\n")
            }
        }
        if isCell {
            elementExtension.append("\t\tcase \(cellName)\n")
        }
        elementExtension.append("\t}\n}")
        return elementExtension
    }

    @discardableResult
    public func conformAccessiblityIdenfiableToView() -> Self? {
        guard let lines = lines,
              var arrayLines = Array(lines) as? Array<String> else { return nil }
        if let firstImportLine = arrayLines.first(where: { $0.contains("import") }),
           let index = arrayLines.firstIndex(of: firstImportLine),
           !arrayLines.contains(where: {$0.contains("import AccessibilityKit")}) {
            arrayLines.insert("import AccessibilityKit", at: abs(index.distance(to: 0)))
        }
        guard let classLine = arrayLines.first(where: { $0.contains("class") && $0.contains(":") }) else { return nil }
        let classLineWords = classLine.split(separator: " ")
        guard let classIndex = classLineWords.firstIndex(of: "class") else { return nil }
        className = String(classLineWords[classIndex + 1])

        className.removeAll { $0 == ":"}
        let interfaceName = className.replacingOccurrences(of: "Controller", with: "")
        //MARK: - Protocol conform AccessibilityIdentifiable
        if let interfaceLine = arrayLines.first(where: { $0.contains("protocol \(interfaceName)") }) {
            if !interfaceLine.contains("AccessibilityIdentifiable") {
                let conformedLine = addAccessibilityIdetifiable(to: interfaceLine)
                guard let interfaceIndex = arrayLines.firstIndex(of: interfaceLine) else { return nil }
                arrayLines.remove(at: abs(interfaceIndex.distance(to: 0)))
                arrayLines.insert(conformedLine, at: abs(interfaceIndex.distance(to: 0)))
            }
        } else if !classLine.contains("AccessibilityIdentifiable") {
            let conformedLine = addAccessibilityIdetifiable(to: classLine)
            guard let interfaceIndex = arrayLines.firstIndex(of: classLine) else { return nil }
            arrayLines.remove(at: abs(interfaceIndex.distance(to: 0)))
            arrayLines.insert(conformedLine, at: abs(interfaceIndex.distance(to: 0)))
        }
        updateLines(from: arrayLines)
        return self
    }

    @discardableResult
    public func conformUITestablePageToView() -> Self? {
        guard let lines = lines,
              var arrayLines = Array(lines) as? Array<String>,
              !outlets.isEmpty else { return nil }
        arrayLines.append("\n// MARK: - UITestable\nextension \(className): UITestablePage {\n")
        arrayLines.append("\ttypealias UIElementType = UIElements.\(className)Elements\n\n")
        arrayLines.append("\tfunc setAccessibilityIdentifiers() {\n")
        for (name, outletType) in outlets {
            arrayLines.append("\t\tmakeViewTestable(\(name), using: .\(name))\n")
            if outletType == "UISearchBar" {
                arrayLines.append("\t\tmakeViewTestable(\(name).textfield, using: .searchTextField)\n")
            }
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
        arrayLines.append(createUIElements(outletNames: outletNames, elementsName: "\(className)Elements", isCell: isCellView, cellName: cellName))
        updateLines(from: arrayLines)
        return self
    }
}
