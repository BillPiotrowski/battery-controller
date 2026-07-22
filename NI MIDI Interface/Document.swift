//
//  Document.swift
//  Temp
//
//  Created by William Piotrowski on 4/30/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Cocoa
import ReactiveSwift

class Document: NSDocument {

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        //let appDelegate = NSApplication.shared.delegate as! AppDelegate
        //let aVariable = appDelegate.someVariable
        
    }

    var documentData: DocumentData?
    
    override class var autosavesInPlace: Bool {
        return true
    }
    var viewController: ViewController? {
        return windowControllers[0].contentViewController as? ViewController
    }
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        
        let documentData = self.documentData ?? DocumentData()
        // FIX FORCED
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let maschineInterface = try! Engine(documentData: documentData, midi: appDelegate.midi!, undoManager: self.undoManager!)
        self.maschineInterface = maschineInterface
        
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let _ = viewController
            else { throw NSError(domain: "No view controller", code: 34, userInfo: nil)}
        guard let documentData = maschineInterface?.documentData
            else { throw NSError(domain: "no document", code: 234, userInfo: nil)}
        //let documentData = documentData

        let jsonData = try JSONSerialization.data(withJSONObject: documentData.dictionary, options: .prettyPrinted)
        return jsonData
        // here "jsonData" is the dictionary encoded in JSON data
        
        // here "decoded" is of type `Any`, decoded from JSON data

        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        
        let decoded = try JSONSerialization.jsonObject(with: data, options: [])
        // here "decoded" is of type `Any`, decoded from JSON data

        // you can now cast it with the right type
        guard let dictFromJSON = decoded as? [String: Any]
            else { throw NSError(domain: "COULD NOT CONVERT TO DICTIONARY", code: 45, userInfo: nil)}
        let documentData = try DocumentData(dictionary: dictFromJSON)
        self.documentData = documentData
        /*
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let maschineInterface = try MaschineInterface(documentData: documentData, midi: appDelegate.midi!)
        self.maschineInterface = maschineInterface
        
        maschineInterface.midi.midiNoteObserver.observe(Signal<MIDINote, Never>.Observer(value: {value in
            dump(value)}))
        
        self.close()
 */
        //self.documentData = documentData
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    var maschineInterface: Engine?
    //var documentData: DocumentData?

    override func shouldCloseWindowController(_ windowController: NSWindowController, delegate: Any?, shouldClose shouldCloseSelector: Selector?, contextInfo: UnsafeMutableRawPointer?){
        dump("SHOULD CLOSE WINDOW!")
        maschineInterface?.dispose()
        maschineInterface = nil
        super.shouldCloseWindowController(windowController, delegate: delegate, shouldClose: shouldCloseSelector, contextInfo: contextInfo)
        dump(maschineInterface)
    }

}

