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
            executeAction(action: action, path: item.path)
        } else if let item = items.menu.compactMap({ $0.subMenu?.first(where: { $0.id == tag }) }).first, let action = item.action {
            executeAction(action: action, path: item.path)
        }
    }
    
    private func executeAction(action: ActionType, path: String?) {
        switch action {
        case .cleanDerivedData:
            "rm -rf \(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/DerivedData").path)/*".runAsCommand()
        case .showHiddenFiles:
            toggleFinderShowAllFiles()
        case .navigate:
            openInFinder(path: path ?? "")
        default:
            break
        }
    }
    
    func openInFinder(path: String) {
        "open \(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(path))".runAsCommand()
    }
    
    func contentsOf(folder: URL) -> [URL] {
      let fileManager = FileManager.default
      do {
        let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
        let urls = contents
          .map { return folder.appendingPathComponent($0) }
        return urls
      } catch {
        return []
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
    
    func toggleFinderShowAllFiles() {
        var newSetting = ""
        let readDefaultsCommand = "defaults read com.apple.Finder AppleShowAllFiles"

        let oldSetting = readDefaultsCommand.runAsCommand()

        // Note: the Command results are terminated with a newline character

        if (oldSetting == "0\n") {
            newSetting = "1"
        } else {
            newSetting = "0"   
        }

        let writeDefaultsCommand = "defaults write com.apple.Finder AppleShowAllFiles \(newSetting); killall Finder"

        _ = writeDefaultsCommand.runAsCommand()

    }
}

extension String {
    func runAsCommand() -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            return "--- Error running command - Unable to initialize string from file data ---"
        }
    }
}
