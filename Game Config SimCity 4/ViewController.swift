//
//  ViewController.swift
//  Game Config
//
//  Created by Sascha Lamprecht on 04.02.22.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var res_selector: NSPopUpButton!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var height: NSTextField!
    
    @IBOutlet weak var custom: NSButton!
    @IBOutlet weak var fullscreen: NSButton!
    @IBOutlet weak var retina_mode: NSButton!
    
    @IBOutlet weak var open_c: NSButton!
    @IBOutlet weak var load_exe: NSButton!
    
    @IBOutlet weak var install_bt: NSButton!
    @IBOutlet weak var save_bt: NSButton!
    @IBOutlet weak var play_bt: NSButton!
 

    @IBOutlet weak var disabler: NSTextField!
   
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.removeObject(forKey: "GameRunning")
        
        syncShellExec(path: scriptPath, args: ["_check_for_game"])
        
        let game_installed = UserDefaults.standard.bool(forKey: "GameInstalled")
        if game_installed == false{
            self.res_selector.isEnabled = false
            self.width.isEnabled = false
            self.height.isEnabled = false
            self.custom.isEnabled = false
            self.fullscreen.isEnabled = false
            self.retina_mode.isEnabled = false
            //self.colored.isEnabled = false
            self.open_c.isEnabled = false
            self.load_exe.isEnabled = false
            self.save_bt.isEnabled = false
            self.play_bt.isEnabled = false
        } else {
            self.res_selector.isEnabled = true
            self.install_bt.isHidden = true
            self.custom.isEnabled = true
            self.fullscreen.isEnabled = true
            self.retina_mode.isEnabled = true
            //self.colored.isEnabled = true
            self.open_c.isEnabled = true
            self.load_exe.isEnabled = true
            self.save_bt.isEnabled = true
            self.save_bt.isHidden = false
            self.play_bt.isEnabled = true
            self.play_bt.isHidden = false
            let check_custom = UserDefaults.standard.bool(forKey: "Custom")
            if check_custom == true{
                self.res_selector.isEnabled = false
                self.width.isEnabled = true
                self.height.isEnabled = true
            } else {
                self.res_selector.isEnabled = true
                self.width.isEnabled = false
                self.height.isEnabled = false
            }
        }
        
        let width = UserDefaults.standard.string(forKey: "Width")
        if width == nil{
            UserDefaults.standard.set("800", forKey: "Width")
            UserDefaults.standard.set("600", forKey: "Height")
            res_selector.selectItem(withTag: 2)
            UserDefaults.standard.set("2", forKey: "Resolution")
        }
        
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = NSLocalizedString("Configurator", comment: "")
    }
    
    @IBAction func custom_config(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
        let check_custom = UserDefaults.standard.bool(forKey: "Custom")
        if check_custom == true{
            self.res_selector.isEnabled = false
            self.width.isEnabled = true
            self.height.isEnabled = true
        } else {
            self.res_selector.isEnabled = true
            self.width.isEnabled = false
            self.height.isEnabled = false
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func install_game(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Read before proceed ...", comment: "")
        alert.informativeText = NSLocalizedString("A Wineskin window will now open. Please insert the 1. Install CD or Image of Zoo Tycoon and do the following:\n\n- Press \"Install Software\"\n- Press\"Choose Setup Executable\"\n-Navigate to Setup Exe and press \"Choose\"\n\nFollow the install instructions of the Windows application. Please don´t change the default install path. Simply accept all. After the installation of Disc 1 is done insert the 2nd one and repeat the whole process.\n\nAt the end of the installation you can close the Installer with the X on the top right corner.\n\nYou can close Wineskin than and restart this Game Config application and you are ready to go.", comment: "")
        alert.alertStyle = .informational
        alert.icon = NSImage(named: "NSError")
        let Button = NSLocalizedString("Ok", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
                
        syncShellExec(path: scriptPath, args: ["_open_wineskin"])
    }
    
    
    @IBAction func language(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["_language"])
    }
    
    @IBAction func open_c(_ sender: Any) {
        let wrapperpath = UserDefaults.standard.string(forKey: "WrapperPath") ?? ""
        NSWorkspace.shared.openFile(wrapperpath + "/Contents/Resources/drive_c")
        //print(wrapperpath + "/Contents/Resources/drive_c")
    }
    
    @IBAction func load_exe(_ sender: Any) {
        let exe = UserDefaults.standard.string(forKey: "WrapperPath")!
        NSWorkspace.shared.launchApplication(exe + "/Wineskin.app")
    }
    
    @IBAction func save_config(_ sender: Any) {
        UserDefaults.standard.set(width.stringValue, forKey: "Width")
        UserDefaults.standard.set(height.stringValue, forKey: "Height")
        syncShellExec(path: scriptPath, args: ["_save_config"])
        self.play_bt.isEnabled = true
        self.save_bt.bezelColor = NSColor.systemGreen
    }
    
    @IBAction func start_game(_ sender: Any) {
        UserDefaults.standard.set(width.stringValue, forKey: "Width")
        UserDefaults.standard.set(height.stringValue, forKey: "Height")
        syncShellExec(path: scriptPath, args: ["_save_config"])
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.run_check), userInfo: nil, repeats: true)
        
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_play"])
                DispatchQueue.main.async {
            }
        }
    }
    
    @IBAction func quit(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func resolution_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
   
    @IBAction func fullscreen_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    
    @IBAction func retina_mode_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func colored_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func width_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func height_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @objc func run_check() {
        syncShellExec(path: scriptPath, args: ["_run_check"])
        let runcheck = UserDefaults.standard.bool(forKey: "GameRunning")
        if runcheck == true {
            play_bt.isEnabled = false
            disabler.isHidden = false
        } else {
            play_bt.isEnabled = true
            disabler.isHidden = true
        }
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

