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
        
        /* Initialize Musashi. */
        m68k_init();
        m68k_set_cpu_type(UInt32.init(M68K_CPU_TYPE_68000))
        m68k_pulse_reset()
        
        /* all righty, let's load us a BIOS */
        jaguar.memory.loadBootROM("/Users/luigi/Documents/Xcode Projects/Jagemu/[BIOS] Atari Jaguar (World).j64")
        
        /* load a little test binary */
        /* 23FC1234 56780010 000060FE */
        cpu_write_long(0x000008, 0x23FC1234);
        cpu_write_long(0x00000C, 0x56780010);
        cpu_write_long(0x000010, 0x000060FE);
        
        m68k_execute(100);
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

