//
//  DebuggerMaster.swift
//  Jagemu
//
//  Created by Kate on 6/29/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa

class Instruction68K : NSObject {
    let address: UInt32
    let size: UInt32
    let disassembly: String
    
    init(address: UInt32, size: UInt32, disassembly: String)
    {
        self.address = address
        self.size = size
        self.disassembly = disassembly
    }
}

class DebuggerMaster : NSObject {
    static let shared = DebuggerMaster()
    
    var CPUDebugWindowController: Debugger68KWindowController
    
    override private init() {
        CPUDebugWindowController = Debugger68KWindowController(windowNibName: NSNib.Name(rawValue: "Debugger68KWindowController"))

        super.init()
    }
    
}
