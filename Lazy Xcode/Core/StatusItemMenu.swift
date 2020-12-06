//
//  StatusItemMenu.swift
//  Lazy Xcode
//
//  Created by aniltaskiran on 26.05.2020.
//  Copyright © 2020 Anıl. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation

// MARK: - StatusItemMenu
struct StatusItemMenu: Codable {
    let menu: [Menu]
}

// MARK: - Menu
struct Menu: Codable {
    let name: String
    let id: Int?
    let type: MenuType
    let subMenu: [Menu]?
    let keyEquivalent: String?
    let action: ActionType?
    let path: String?
}

enum MenuType: String, Codable {
    case menu = "MENU"
    case seperator = "SEPERATOR"
    case submenu = "SUBMENU"
    case quit = "QUIT"
}

enum ActionType: String, Codable {
    case cleanDerivedData = "CLEANDERIVEDDATA"
    case showHiddenFiles = "SHOWHIDDENFILES"
    case createIOSPlayground = "CREATEIOSPLAYGROUND"
    case createMacOSPlayground = "CREATEMACOSPLAYGROUND"
    case createTvOSPlayground = "CREATETVOSPLAYGROUND"
    case navigate = "NAVIGATE"
}

// MARK: - {
extension StatusItemMenu {
    init?(jsonResource: String) {
        guard let data = Data(fromResource: jsonResource, type: "json"),
            let statusItemMenu = try? JSONDecoder().decode(StatusItemMenu.self, from: data) else {
            return nil
        }
        self = statusItemMenu
    }
}
// MARK: - {
extension Data {
    init?(fromResource path: String, type: String) {
        guard let path = Bundle.main.path(forResource: path, ofType: type),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) else {
            return nil
        }

        self = data
    }
}
