//
//  StatusItemController.swift
//  Lazy Xcode
//
//  Created by aniltaskiran on 26.05.2020.
//  Copyright © 2020 Anıl. All rights reserved.
//
import Cocoa

final class StatusItemController {
    let items: StatusItemMenu
    let statusItem: NSStatusItem
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        items.menu.forEach({ item in
            switch item.type {
            case .menu:
                let menuItem = NSMenuItem(title: item.name, action: #selector(AppDelegate.menuItemClicked(sender:)), keyEquivalent: item.keyEquivalent ?? "")
                menuItem.tag = item.id ?? 0
                menu.addItem(menuItem)
            case .submenu:
                let menuItem = NSMenuItem()
                menuItem.title = item.name
                
                let subMenu = NSMenu()
                
                item.subMenu?.forEach({ sub in
                    let subMenuItem = NSMenuItem(title: sub.name, action: #selector(AppDelegate.menuItemClicked(sender:)), keyEquivalent: sub.keyEquivalent ?? "")
                    subMenuItem.tag = sub.id ?? 0
                    subMenu.addItem(subMenuItem)
                })
                
                menuItem.submenu = subMenu
                menu.addItem(menuItem)
            case .seperator:
                menu.addItem(NSMenuItem.separator())
            case .quit:
                let quitItem = NSMenuItem(title: item.name, action: #selector(NSApplication.terminate(_:)), keyEquivalent: item.keyEquivalent ?? "")
               menu.addItem(quitItem)
            }
        })
        return menu
    }
    
    func itemClickedWith(tag: Int) {
        if let item = items.menu.first(where: { $0.id == tag }), let action = item.action {
            executeAction(action: action)
        } else if let item = items.menu.compactMap({ $0.subMenu?.first(where: { $0.id == tag }) }).first, let action = item.action {
            executeAction(action: action)
        }
    }
    
    private func executeAction(action: ActionType) {
        switch action {
        case .cleanDerivedData:
            print("clean derived data")
        default:
            break
        }
    }
    
    init() {
        items = StatusItemMenu.init(jsonResource: "StatusItemControllerResponse") ?? .init(menu: [])
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = createMenu()
        let image = NSImage(named: "PlayAlways")
        image?.isTemplate = true
        statusItem.button?.image = image
//        statusItem.image?.isTemplate = true
    }
}
