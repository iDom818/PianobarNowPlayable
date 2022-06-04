import Cocoa
import Foundation
import AVFoundation
import MediaPlayer

class PianobarPlayer {
    
    static let shared: PianobarPlayer? = {
        do {
            return try PianobarPlayer()
        } catch {
            NSLog("Failed to initialize Pianobar Player: %@", [error])
            return nil
        }
    }()
    
    // Generic audio file since we don't have access to the file streamed from Pandora
    let blankAudioUrl = Bundle.main.url(forResource: "1-second-of-silence", withExtension: ".m4a")!
    
    // TODO: These should be based on the pianobar config for users with non default controls
    enum PianobarCommand: String {
        case playPause = "p"
        case next = "n"
        case love = "+"
        case ban = "-"
    }
    
    private let nowPlayableBehavior: NowPlayable = PianobarNowPlayableBehavior()
    
    private var isPlaying: Bool = true {
        didSet {
            handlePlaybackChange()
        }
    }
    private var isInterrupted: Bool = false
    
    init() throws {
        try nowPlayableBehavior.handleNowPlayableConfiguration(
                commands: nowPlayableBehavior.defaultRegisteredCommands,
                disabledCommands: nowPlayableBehavior.defaultDisabledCommands,
                commandHandler: handleCommand(command:event:),
                interruptionHandler: handleInterrupt(with:))
        
        try nowPlayableBehavior.handleNowPlayableSessionStart()
        setNowPlayingInformationToDefault()
        handlePlaybackChange()
    }
    
    func optOut() {
        nowPlayableBehavior.handleNowPlayableSessionEnd()
    }
    
    func invertIsPlaying() {
        isPlaying = !isPlaying
    }
    
    func togglePlayPause() {
        invertIsPlaying()
        sendCommandToPianobar(PianobarCommand.playPause)
    }
    
    func nextSong() {
        sendCommandToPianobar(PianobarCommand.next)
    }
    
    func loveSong() {
        sendCommandToPianobar(PianobarCommand.love)
    }
    
    func banSong() {
        sendCommandToPianobar(PianobarCommand.ban)
    }
    
    private func sendCommandToPianobar(_ pianobarCommand: PianobarCommand) {
        NSLog("Sending command to pianobar: \(pianobarCommand)")
        let sendCommandWorkItem = DispatchWorkItem {
            let pianobarFifo = NSString(string: "~/.config/pianobar/ctl").expandingTildeInPath
            let handler = FileHandle(forWritingAtPath: pianobarFifo)
            if let dataToWrite = pianobarCommand.rawValue.data(using: .utf8) {
                handler?.write(dataToWrite)
            }
            handler?.closeFile()
        }
        DispatchQueue.global().async(execute: sendCommandWorkItem)
        
    }
    
    private func setNowPlayingInformationToDefault() {
        let metadata = NowPlayableStaticMetadata(
                assetURL: blankAudioUrl,
                mediaType: .audio,
                isLiveStream: false,
                title: "Pianobar",
                artist: "Pianobar",
                artwork: nil,
                albumArtist: "Pianobar",
                albumTitle: "Pianobar")
        nowPlayableBehavior.handleNowPlayableItemChange(metadata: metadata)
    }
    
    func setNowPlayingInformation(title: String, artist: String, album: String, albumArtUrl: String) {
        // If we receive now playing information, pianobar is most likely playing
        if (!isPlaying) {
            invertIsPlaying()
        }
        
        let metadata = NowPlayableStaticMetadata(
                assetURL: blankAudioUrl,
                mediaType: .audio,
                isLiveStream: false,
                title: title,
                artist: artist,
                artwork: getMediaArtwork(for: albumArtUrl),
                albumArtist: artist,
                albumTitle: album)
        nowPlayableBehavior.handleNowPlayableItemChange(metadata: metadata)
    }
    
    private func getMediaArtwork(for urlString: String) -> MPMediaItemArtwork? {
        if (urlString.isEmpty) {
            return nil
        }
        
        // App Transport Security requires HTTPS
        var httpsUrlString = urlString;
        if (urlString.starts(with: "http://")) {
            httpsUrlString = "https" + urlString.dropFirst(4)
        }
        
        guard let url = URL(string: httpsUrlString),
              let image = NSImage(contentsOf: url) else {
            return nil
        }
        return MPMediaItemArtwork(boundsSize: image.size) { _ in
            image
        }
    }
    
    private func handlePlaybackChange() {
        // TODO: Find a way to listen to the playback time of pianobar
        let metadata = NowPlayableDynamicMetadata(
                rate: 0.0,
                position: 0.0,
                duration: 0.0,
                currentLanguageOptions: [],
                availableLanguageOptionGroups: [])
        nowPlayableBehavior.handleNowPlayablePlaybackChange(playing: isPlaying, metadata: metadata)
    }
    
    private func handleCommand(command: NowPlayableCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        NSLog("Handling remote command \(command)")
        switch command {
        case .play where !isPlaying:
            togglePlayPause()
        case .pause where isPlaying:
            togglePlayPause()
        case .togglePausePlay:
            togglePlayPause()
        case .nextTrack:
            nextSong()
        case .like:
            loveSong()
        case .dislike:
            banSong()
        case .stop:
            optOut()
        default:
            break
        }
        return .success
    }
    
    // TODO: Need to find a way to detect interrupts on macOS
    private func handleInterrupt(with interruption: NowPlayableInterruption) {
        switch interruption {
        case .began:
            isInterrupted = true
        case .ended(let shouldPlay):
            isInterrupted = false
            if (shouldPlay) {
                togglePlayPause()
            }
        case .failed(let error):
            NSLog(error.localizedDescription)
            optOut()
        }
    }
}
