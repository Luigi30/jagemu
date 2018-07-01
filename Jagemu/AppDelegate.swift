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

    @IBOutlet weak var window: JaguarWindow!
    
    var jaguar: JaguarSystem? = nil
    let debugger: DebuggerMaster = DebuggerMaster.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        jaguar = JaguarSystem.sharedJaguar() as? JaguarSystem
        window.setupMetalView()
        jaguar!.screen = window.metalView
        
        debugger.CPUDebugWindowController.showWindow(nil)

        /* Initialize Musashi. */
        m68k_init();
        m68k_set_cpu_type(UInt32.init(M68K_CPU_TYPE_68000))
        m68k_pulse_reset()
        
        /* all righty, let's load us a BIOS */
        jaguar!.memory.loadBootROM("/Users/luigi/Documents/Xcode Projects/Jagemu/[BIOS] Atari Jaguar (World).j64")
        print(jaguar!.memory.bootROM[0xE00010])
        print(cpu_read_byte(0xE00010))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

