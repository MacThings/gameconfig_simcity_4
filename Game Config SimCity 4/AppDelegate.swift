//
//  AppDelegate.swift
//  Game Config
//
//  Created by Sascha Lamprecht on 04.02.22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.removeObject(forKey: "GameRunning")
        syncShellExec(path: scriptPath, args: ["_kill_wine"])
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_
        theApplication: NSApplication) -> Bool {
        return true
    }

    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        process.waitUntilExit()
    }
    
}

