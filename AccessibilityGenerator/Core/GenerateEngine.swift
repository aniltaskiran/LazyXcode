//
//  GenerateEngine.swift
//  AccessibilityGenerator
//
//  Created by Aytuğ Sevgi on 20.09.2021.
//

import Foundation

public class GenerateEngine {
    static var shared: GenerateEngine { GenerateEngine() }
    private let items: [Generatable] = [MarkGenerator(), AccessibilityGenerator(), UITestablePageGenerator(), SortGenerate()]

    public func generate(identifier: String, lines: NSMutableArray?) {
        items.first { $0.isSatisfied(identifier: identifier) }?.execute(lines: lines)
    }
}
