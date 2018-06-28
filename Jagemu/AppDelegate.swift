//
//  AppDelegate.swift
//  Jagemu
//
//  Created by Kate on 6/27/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let jaguar: JaguarSystem = JaguarSystem()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        /* all righty, let's load us a BIOS */
        // TODO: picker
        jaguar.memory.loadBootROM("/Users/luigi/Documents/Xcode Projects/Jagemu/[BIOS] Atari Jaguar (World).j64")
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

