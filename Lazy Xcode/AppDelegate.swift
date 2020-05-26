//
//  AppDelegate.swift
//  Lazy Xcode
//
//  Created by aniltaskiran on 24.05.2020.
//  Copyright © 2020 Anıl. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemController: StatusItemController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItemController = .init()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func menuItemClicked(sender: NSMenuItem) {
        guard sender.tag != 0 else { return }
        statusItemController?.itemClickedWith(tag: sender.tag)
    }
}
