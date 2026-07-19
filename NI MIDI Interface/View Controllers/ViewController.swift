//
//  ViewController.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Cocoa
import ReactiveSwift




class ViewController: NSViewController, NSComboBoxDataSource {
    @IBOutlet weak var keyboardSourcePopupMenu: NSPopUpButton!
    @IBOutlet weak var controllerSourcePopupButton: NSPopUpButton!
    @IBOutlet weak var controllerDevicePopupButton: NSPopUpButton!
    @IBOutlet weak var samplerOutputPopupButton: NSPopUpButton!
    
    weak var controllerInputVC: MidiDeviceSelectionViewController?
    weak var toControllerVC: MidiOutputSelectionViewController?
    weak var toSamplerVC: MidiOutputSelectionViewController?
    
    @IBOutlet weak var controllerInputTableView: NSTableView!
    
    @IBOutlet var keyboardSourceArrayController: NSArrayController!
    @IBOutlet var controllerSourceArrayController: NSArrayController!
    @IBOutlet var outputDeviceController: NSArrayController!
    @IBOutlet var samplerOutputDeviceArray: NSArrayController!
    
    var maschineInterface: MaschineInterface?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        let document = self.view.window?.windowController?.document as! Document
        self.maschineInterface = document.maschineInterface
        
        /*
        let samplerOutputDeviceSelection = maschineInterface!.samplerOutputSelection.midiDeviceSelection.value
        */
       
           /* .maschineInterface!.controllerInput.options.signal.observe(Signal<[MidiInputInfo], Never>.Observer(value: {val in
            self.controllerInputTableView.reloadData()
        }))
         maschineInterface!.samplerOutputSelection.midiDeviceSelection.signal.observe(Signal<[MidiOutputInfo], Never>.Observer(value: {value in
            self.samplerOutputDeviceArray.content = value
        })) self.maschineInterface!.controllerOutputDevice.midiDeviceSelection.signal.observe(Signal<[MidiOutputInfo], Never>.Observer(value: { value in
        self.outputDeviceController.content = self.maschineInterface!.controllerOutputDevice.midiDeviceSelection.value
                   }))

        */
        //outputDeviceController.content = maschineInterface!.controllerOutputDevice.midiDeviceSelection.value
        //samplerOutputDeviceArray.content = maschineInterface!.samplerOutputSelection.midiDeviceSelection.value
        //controllerSourceArrayController.content = maschineInterface!.controllerInput.options.value
        //keyboardSourceArrayController.content = maschineInterface!.keyboardInput.options.value

 //controllerInputTableView.delegate = self
 //controllerInputTableView.dataSource = self
  //      controllerInputTableView.reloadData()
        
        controllerInputVC?.midiInput = maschineInterface!.controllerInput
        controllerInputVC?.tableView.reloadData()
        
        toControllerVC?.midiOutput = maschineInterface?.controllerOutputDevice
        toControllerVC?.tableView.reloadData()
        
        toSamplerVC?.midiOutput = maschineInterface?.samplerOutputSelection
        toSamplerVC?.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: ACTIONS
extension ViewController {
    @IBAction func controllerSourcePopupButtonAction(_ sender: NSPopUpButton) {
        //maschineInterface?.controllerInput.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func keyboardSourcePopupMenuAction(_ sender: NSPopUpButton) {
        //maschineInterface?.keyboardInput.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func controllerDevicePopupButtonAction(_ sender: NSPopUpButton) {
        maschineInterface?.controllerOutputDevice.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func samplerOutputPopupButtonAction(_ sender: NSPopUpButton) {
        maschineInterface?.samplerOutputSelection.setDevice(index: sender.indexOfSelectedItem)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedChildSegue" {
            guard
                let childVC = segue.destinationController as? MidiDeviceSelectionViewController
                else {
                    print("WRONG VC TYPE")
                    return
            }
            self.controllerInputVC = childVC
            guard let maschineInterface = maschineInterface
                
                else {
                    print("maschine interface missing")
                    return
            }
            childVC.midiInput = maschineInterface.controllerInput
            
        }
        if segue.identifier == "toControllerSegue" {
            
            guard
                let childVC = segue.destinationController as? MidiOutputSelectionViewController
                else {
                    print("WRONG VC TYPE")
                    return
            }
            self.toControllerVC = childVC
            guard let maschineInterface = maschineInterface
                else {
                    print("maschine interface missing")
                    return
            }
            childVC.midiOutput = maschineInterface.controllerOutputDevice
        }
        if segue.identifier == "toSamplerSegue" {
            
            guard
                let childVC = segue.destinationController as? MidiOutputSelectionViewController
                else {
                    print("WRONG VC TYPE")
                    return
            }
            self.toSamplerVC = childVC
            guard let maschineInterface = maschineInterface
                else {
                    print("maschine interface missing")
                    return
            }
            childVC.midiOutput = maschineInterface.samplerOutputSelection
        }
      
 
    }
    
}

/*
extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return maschineInterface!.controllerInput.options.value.count
    }

    fileprivate enum CellIdentifiers {
      static let enableCell = "enableCellID"
      static let nameCell = "nameCellID"
      static let channelCell = "channelCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        
        //var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""

        //let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        //dateFormatter.timeStyle = .long
        
        print("ROW: \(row)")
        
        // 1
        let item = maschineInterface!.controllerInput.options.value[row]

        // 2
        if tableColumn == tableView.tableColumns[0] {
          //image = item.icon
            text = item.name
            print(item)
            cellIdentifier = CellIdentifiers.enableCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.name
          cellIdentifier = CellIdentifiers.nameCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.name
          cellIdentifier = CellIdentifiers.channelCell
        }

        // 3
        
        
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
          cell.textField?.stringValue = text
          //cell.imageView?.image = image ?? nil
          return cell
        }
        print("BAD")
        return nil
      }

    
}

*/
