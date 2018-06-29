//
//  Debugger68KWindowController.swift
//  Jagemu
//
//  Created by Kate on 6/28/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa

class Debugger68KWindowController: NSWindowController {

    @IBOutlet weak var reg68K_A0: NSTextField!
    @IBOutlet weak var reg68K_A1: NSTextField!
    @IBOutlet weak var reg68k_A2: NSTextField!
    @IBOutlet weak var reg68k_A3: NSTextField!
    @IBOutlet weak var reg68k_A4: NSTextField!
    @IBOutlet weak var reg68k_A5: NSTextField!
    @IBOutlet weak var reg68k_A6: NSTextField!
    @IBOutlet weak var reg68k_A7: NSTextField!
    
    @IBOutlet weak var reg68k_D0: NSTextField!
    @IBOutlet weak var reg68k_D1: NSTextField!
    @IBOutlet weak var reg68k_D2: NSTextField!
    @IBOutlet weak var reg68k_D3: NSTextField!
    @IBOutlet weak var reg68k_D4: NSTextField!
    @IBOutlet weak var reg68k_D5: NSTextField!
    @IBOutlet weak var reg68k_D6: NSTextField!
    @IBOutlet weak var reg68k_D7: NSTextField!
    
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name(rawValue: "Debugger68KWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
