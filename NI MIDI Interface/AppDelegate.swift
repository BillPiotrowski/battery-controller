//
//  AppDelegate.swift
//  NI MIDI Interface
//
//  Created by William Piotrowski on 4/29/20.
//  Copyright © 2020 William Piotrowski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var midi: MIDI? = MIDI()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        midi = nil
        // Insert code here to tear down your application
    }


}

