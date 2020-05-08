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
    
    @IBOutlet var keyboardSourceArrayController: NSArrayController!
    @IBOutlet var controllerSourceArrayController: NSArrayController!
    @IBOutlet var outputDeviceController: NSArrayController!
    @IBOutlet var samplerOutputDeviceArray: NSArrayController!
    
    var maschineInterface: MaschineInterface!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        let document = self.view.window?.windowController?.document as! Document
        self.maschineInterface = document.maschineInterface
        
        /*
        let samplerOutputDeviceSelection = maschineInterface!.samplerOutputSelection.midiDeviceSelection.value
        */
        maschineInterface!.samplerOutputSelection.availableDevices.signal.observe(Signal<MidiDeviceSelectionStruct, Never>.Observer(value: {value in
            self.samplerOutputDeviceArray.content = self.maschineInterface.samplerOutputSelection.availableDevices.value.options
        }))
    self.maschineInterface.controllerOutputDevice.availableDevices.signal.observe(Signal<MidiDeviceSelectionStruct, Never>.Observer(value: { value in
        self.outputDeviceController.content = self.maschineInterface.controllerOutputDevice.availableDevices.value.options
                   }))
        
        outputDeviceController.content = maschineInterface.controllerOutputDevice.availableDevices.value.options
        samplerOutputDeviceArray.content = maschineInterface.samplerOutputSelection.availableDevices.value.options
        controllerSourceArrayController.content = maschineInterface.controllerSourceSelection.midiSourceSelection.value.options
        keyboardSourceArrayController.content = maschineInterface.keyboardSourceSelection.midiSourceSelection.value.options
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: ACTIONS
extension ViewController {
    @IBAction func controllerSourcePopupButtonAction(_ sender: NSPopUpButton) {
        maschineInterface.controllerSourceSelection.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func keyboardSourcePopupMenuAction(_ sender: NSPopUpButton) {
        maschineInterface.keyboardSourceSelection.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func controllerDevicePopupButtonAction(_ sender: NSPopUpButton) {
        maschineInterface.controllerOutputDevice.setDevice(index: sender.indexOfSelectedItem)
    }
    @IBAction func samplerOutputPopupButtonAction(_ sender: NSPopUpButton) {
        maschineInterface.samplerOutputSelection.setDevice(index: sender.indexOfSelectedItem)
    }
}
