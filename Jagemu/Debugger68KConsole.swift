//
//  Debugger68KConsole.swift
//  Jagemu
//
//  Created by Kate on 7/7/18.
//  Copyright © 2018 Luigi Thirty. All rights reserved.
//

import Foundation

class Debugger68KConsole: NSObject
{
    let jaguar: JaguarSystem = JaguarSystem.sharedJaguar() as! JaguarSystem
    
    func processCommand(commandString: String) -> String
    {
        return String.init(format: "processCommand: %@", commandString)
    }
}
