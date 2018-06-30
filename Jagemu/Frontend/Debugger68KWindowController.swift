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
    
    @IBOutlet weak var reg68k_PC: NSTextField!
    @IBOutlet weak var reg68k_SR: NSTextField!
    
    @IBOutlet weak var disassemblyTableView: NSTableView!
    
    @IBOutlet weak var disasmAddressField: NSTextField!
    
    let jaguar: JaguarSystem = JaguarSystem.sharedJaguar() as! JaguarSystem
    var disassembledInstructions: [Instruction68K] = []
    
    override var windowNibName: NSNib.Name?
    {
        return NSNib.Name(rawValue: "Debugger68KWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        setupTableView()
    }
    
    func setupTableView() {
        disassemblyTableView.delegate = self
        disassemblyTableView.dataSource = self
        disassemblyTableView.reloadData()
    }
    
    func updateRegisterDisplays()
    {
        reg68K_A0.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A0))
        reg68K_A1.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A1))
        reg68k_A2.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A2))
        reg68k_A3.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A3))
        reg68k_A4.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A4))
        reg68k_A5.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A5))
        reg68k_A6.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A6))
        reg68k_A7.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_A7))
        
        reg68k_D0.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D0))
        reg68k_D1.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D1))
        reg68k_D2.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D2))
        reg68k_D3.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D3))
        reg68k_D4.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D4))
        reg68k_D5.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D5))
        reg68k_D6.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D6))
        reg68k_D7.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_D7))
        
        reg68k_PC.stringValue = String(format: "%08X", m68k_get_reg(nil, M68K_REG_PC))
        reg68k_SR.stringValue = String(format: "%04X", m68k_get_reg(nil, M68K_REG_SR))
    }
    
    func disassembleFromAddress(address: UInt32)
    {
        disassembledInstructions.removeAll()
        
        var msgBuf = [CChar](repeating: 0, count: 200)
        var size: UInt32 = 0
        var curpc: UInt32 = address
        
        for _ in 0..<50
        {
            size = m68k_disassemble(&msgBuf, curpc, UInt32(M68K_CPU_TYPE_68000))
            disassembledInstructions.append(Instruction68K(address: curpc, size: size, disassembly: String.init(cString: msgBuf)))
            curpc += size
        }
        
        disassemblyTableView.reloadData()
    }
    
    @IBAction func runJaguarButton(_ sender: Any) {
        jaguar.runJag(forCycles: 100)
        updateRegisterDisplays()
    }
    
    @IBAction func disassembleButton(_ sender: Any) {
        guard let address = UInt32(disasmAddressField.stringValue, radix: 16) else {
            print("Invalid address to disassemble from")
            return
        }
        
        disassembleFromAddress(address: address)
    }
}

/*****/

extension Debugger68KWindowController: NSTableViewDataSource {
    /* TableViewDataSource stuff */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return disassembledInstructions.count
    }
}

extension Debugger68KWindowController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let addressCell = "InstAddressCellID"
        static let dasmCell = "InstDisasmCellID"
        static let opcodeCell = "InstOpcodeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellID: String = ""
        var cellText: String = ""
        
        if disassembledInstructions.isEmpty {
            return nil
        }
        
        let instruction = disassembledInstructions[row]
        
        if tableColumn == tableView.tableColumns[0] {
            cellID = CellIdentifiers.addressCell
            cellText = String(format: "%06X", instruction.address)
        }
        else if tableColumn == tableView.tableColumns[1] {
            cellID = CellIdentifiers.dasmCell
            cellText = String(instruction.disassembly)
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = cellText
            cell.textField?.font = NSFont.init(name: "Monaco", size: 12)
            return cell
        }
        
        return nil
    }
}
