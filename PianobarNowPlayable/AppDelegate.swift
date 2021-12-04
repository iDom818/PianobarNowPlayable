import Cocoa
import MediaPlayer
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var launchAtLoginMenuItem: NSMenuItem!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private var pianobarPlayer: PianobarPlayer? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("Starting PianobarNowPlayable")
        statusItem.button?.image = NSImage(named: "MenuIcon")
        statusItem.menu = statusMenu
        
        updateLaunchAtLoginMenuItem()
        
        pianobarPlayer = PianobarPlayer.shared
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        NSLog("Terminating PianobarNowPlayable")
        pianobarPlayer?.optOut()
        pianobarPlayer = nil
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
    
    @IBAction func onPlayPause(_ sender: NSMenuItem) {
        pianobarPlayer?.togglePlayPause()
    }
    
    @IBAction func onNextSong(_ sender: NSMenuItem) {
        pianobarPlayer?.nextSong()
    }
    
    @IBAction func onLoveSong(_ sender: NSMenuItem) {
        pianobarPlayer?.loveSong()
    }
    
    @IBAction func onBanSong(_ sender: NSMenuItem) {
        pianobarPlayer?.banSong()
    }
    
    @IBAction func onLaunchAtLogin(_ sender: NSMenuItem) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        updateLaunchAtLoginMenuItem()
    }
    
    private func updateLaunchAtLoginMenuItem() {
        launchAtLoginMenuItem.state = LaunchAtLogin.isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @IBAction func onSwapPlayPauseState(_ sender: NSMenuItem) {
        pianobarPlayer?.invertIsPlaying()
    }
    
    @IBAction func onQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}

