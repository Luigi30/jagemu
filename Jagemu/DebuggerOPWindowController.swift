//
//  DebuggerOPWindowController.swift
//  Jagemu
//
//  Created by Kate on 7/11/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa

class DebuggerOPWindowController: NSWindowController {

    let jaguar: JaguarSystem = JaguarSystem.sharedJaguar() as! JaguarSystem
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name(rawValue: "DebuggerOPWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
