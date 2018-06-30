//
//  JaguarWindow.swift
//  Jagemu
//
//  Created by Kate on 6/30/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Cocoa

class JaguarWindow: NSWindow {
    var metalView: JaguarScreenView!
    
    func setupMetalView()
    {
        metalView = JaguarScreenView(w: 320, h: 256)
        self.contentView?.addSubview(metalView)
    }
}
