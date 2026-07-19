//
//  MidiDeviceSelectionViewController.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 5/8/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Cocoa
import ReactiveSwift

class MidiDeviceSelectionViewController: NSViewController {
    var midiInput: MidiInput? {
        didSet {
            midiInput?.options.signal.observe(
                Signal<[MidiInputInfo], Never>.Observer(
                    value: {value in
                        print("new inputs!")
                       self.tableView.reloadData()
                   }
                )
            )
        }
    }

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension MidiDeviceSelectionViewController: NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return midiInput?.options.value.count ?? 0
    }
}

extension MidiDeviceSelectionViewController: NSTableViewDataSource {

    fileprivate enum CellIdentifiers {
      static let enableCell = "enableCellID"
      static let nameCell = "deviceCellID"
      static let channelCell = "channelCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        
        //var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""

        //let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        //dateFormatter.timeStyle = .long
        
        //print("ROW: \(row)")
        
        // 1
        guard let item = midiInput?.options.value[row]
            else {
                print("MISSING CELL INFO")
                return nil
        }

        // 2
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = CellIdentifiers.enableCell
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! CheckBoxTableViewCell
            cell.delegate = self
            cell.checkBox.state = item.active ? .on : .off
              //cell.textField?.stringValue = text
              //cell.imageView?.image = image ?? nil
              return cell
            
          //image = item.icon
            //text = item.
            //print(item)
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
extension MidiDeviceSelectionViewController: CheckBoxTableCellViewDelegate {
    func checkBoxChanged(tableCellView: NSTableCellView, checked: Bool) {
        let row = tableView.row(for: tableCellView)
        guard row >= 0
            else {
                print("ERROR: Could not determine row.")
                return
        }
        guard let midiInput = midiInput
            else {
                print("ERROR: No midi input set. Could not connect / disconnect source.")
                return
        }
        switch checked {
        case true:
            do {
                try midiInput.connect(input: midiInput.options.value[row])
            } catch {
                print("ERROR connected: \(error)")
            }
        case false: midiInput.disconnect(input: midiInput.options.value[row])
        }
    }
    
    
}


protocol CheckBoxTableCellViewDelegate {
    func checkBoxChanged(tableCellView: NSTableCellView, checked: Bool)
}

class CheckBoxTableViewCell: NSTableCellView {
    var delegate: CheckBoxTableCellViewDelegate?
    
    @IBOutlet weak var checkBox: NSButton!
    
    @IBAction func checkBoxAction(_ sender: NSButton) {
        guard let delegate = delegate
            else {
                print("ERROR: No delegate for checkbox.")
                return
        }
        let checked: Bool
        switch sender.state {
        case .on: checked = true
        default: checked = false
        }
        delegate.checkBoxChanged(tableCellView: self, checked: checked)
    }
}
