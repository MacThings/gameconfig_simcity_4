//
//  ViewController.swift
//  Game Config
//
//  Created by Sascha Lamprecht on 04.02.22.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

  
    @IBOutlet weak var cpu_cores: NSPopUpButton!
    @IBOutlet weak var priority: NSPopUpButton!
    
    @IBOutlet weak var res_selector: NSPopUpButton!
    @IBOutlet weak var width: NSTextField!
    @IBOutlet weak var height: NSTextField!
    
    @IBOutlet weak var custom: NSButton!
    @IBOutlet weak var fullscreen: NSButton!
    @IBOutlet weak var retina_mode: NSButton!
    @IBOutlet weak var play_intro: NSButton!
    @IBOutlet weak var autosave: NSButton!
    
    @IBOutlet weak var open_c: NSButton!
    @IBOutlet weak var load_exe: NSButton!
    
    @IBOutlet weak var install_bt: NSButton!
    @IBOutlet weak var save_bt: NSButton!
    @IBOutlet weak var play_bt: NSButton!

    @IBOutlet weak var change_language: NSButton!
    @IBOutlet weak var disabler: NSTextField!
    
    @IBOutlet weak var autosave_checkbox: NSButton!
    @IBOutlet weak var autosave_field: NSTextField!
    @IBOutlet weak var autosave_stepper: NSStepper!
    
   
    
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
            self.play_intro.isEnabled = false
            self.autosave.isEnabled = false
            self.change_language.isEnabled = false
            self.open_c.isEnabled = false
            self.load_exe.isEnabled = false
            self.save_bt.isEnabled = false
            self.play_bt.isEnabled = false
            self.autosave_checkbox.isEnabled = false
            self.autosave_field.isEnabled = false
            self.autosave_stepper.isEnabled = false
        } else {
            self.res_selector.isEnabled = true
            self.install_bt.isHidden = true
            self.custom.isEnabled = true
            self.fullscreen.isEnabled = true
            self.retina_mode.isEnabled = true
            self.play_intro.isEnabled = true
            self.autosave.isEnabled = true
            self.change_language.isEnabled = true
            self.open_c.isEnabled = true
            self.load_exe.isEnabled = true
            self.save_bt.isEnabled = true
            self.save_bt.isHidden = false
            self.play_bt.isEnabled = true
            self.play_bt.isHidden = false
            self.autosave_checkbox.isEnabled = true
            self.autosave_field.isEnabled = true
            self.autosave_stepper.isEnabled = true
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
        
        let intro = UserDefaults.standard.string(forKey: "Intro")
        if intro == nil{
            UserDefaults.standard.set(false, forKey: "Intro")
        }
        
        syncShellExec(path: scriptPath, args: ["_get_cores"])
        
        let count_cores = NSString(string:"/private/tmp/cpucores").expandingTildeInPath
        let fileContent = try? NSString(contentsOfFile: count_cores, encoding: String.Encoding.utf8.rawValue)
        for (_, cores) in (fileContent?.components(separatedBy: "\n").enumerated())! {
            self.cpu_cores.menu?.addItem(withTitle: cores, action: #selector(ViewController.menuItemClicked(_:)), keyEquivalent: "")
        }
        
        let selected_cores = UserDefaults.standard.string(forKey: "SelectedCores")
        if selected_cores == nil{
            let cores = UserDefaults.standard.string(forKey: "PhysicalCores") ?? ""
            cpu_cores.selectItem(withTitle:cores)
            self.cpu_cores.item(withTitle: "")?.isHidden=true
            UserDefaults.standard.set(cores, forKey: "SelectedCores")
        } else {
            cpu_cores.selectItem(withTitle:selected_cores!)
            self.cpu_cores.item(withTitle: "")?.isHidden=true
        }
        
        let priority = UserDefaults.standard.string(forKey: "Priority")
        if priority == nil{
            UserDefaults.standard.set("3", forKey: "Priority")
        }
        
        let autosave = UserDefaults.standard.string(forKey: "Autosave")
        if autosave == nil{
            UserDefaults.standard.set(false, forKey: "Autosave")
        }
        
        let save_interval = UserDefaults.standard.string(forKey: "SaveInterval")
        if save_interval == nil{
            UserDefaults.standard.set("10", forKey: "SaveInterval")
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
    
    @IBAction func language(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["_language"])
    }
    
    @IBAction func open_c(_ sender: Any) {
        let wrapperpath = UserDefaults.standard.string(forKey: "WrapperPath") ?? ""
        NSWorkspace.shared.openFile(wrapperpath + "/Contents/Resources/drive_c")
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
        UserDefaults.standard.removeObject(forKey: "GameRunning")
        syncShellExec(path: scriptPath, args: ["_kill_wine"])
        exit(0)
    }
    
    @IBAction func resolution_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func cores_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func priority_activity(_ sender: Any) {
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
    
    @IBAction func play_intro_activity(_ sender: Any) {
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
    
    @IBAction func autosave_checkbox_activity(_ sender: Any) {
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func autosave_fieldactivity(_ sender: Any) {
        //self.play_bt.isEnabled = false
        //self.save_bt.bezelColor = NSColor.red
    }
    
    @IBAction func autosave_stepper_activity(_ sender: Any) {
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
            syncShellExec(path: scriptPath, args: ["_kill_autosave"])
            play_bt.isEnabled = true
            disabler.isHidden = true
        }
    }
    
    @IBAction func browseFile_setup_exe(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["exe"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let pid: Int32 = ProcessInfo.processInfo.processIdentifier
                let pid2 = String(pid)
                UserDefaults.standard.set(pid2, forKey: "SetupPID")
                
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Read before proceed!", comment: "")
                alert.informativeText = NSLocalizedString("When the installation in Windows has been completed, close the setup program. Don't open the game just yet!\n\nThe Game Config app will restart automatic and than you can press \"Play\"", comment: "")
                alert.alertStyle = .informational
                alert.icon = NSImage(named: "NSError")
                let Button = NSLocalizedString("Ok", comment: "")
                alert.addButton(withTitle: Button)
                alert.runModal()
                
                let path = result!.path
                let dlpath = (path as String)
                UserDefaults.standard.set(dlpath, forKey: "SetupExe")
                
                DispatchQueue.global(qos: .background).async {
                    self.syncShellExec(path: self.scriptPath, args: ["_setup_exe"])
                        DispatchQueue.main.async {
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @objc func menuItemClicked(_ sender: NSMenuItem) {
        self.cpu_cores.item(withTitle: "")?.isHidden=true
        let selected_cores = self.cpu_cores.titleOfSelectedItem
        UserDefaults.standard.set(selected_cores, forKey: "SelectedCores")
        self.play_bt.isEnabled = false
        self.save_bt.bezelColor = NSColor.red
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

