import Foundation
import MediaPlayer

class PianobarNowPlayableBehavior: NowPlayable {
    
    var defaultAllowsExternalPlayback: Bool {
        true
    }
    
    var defaultRegisteredCommands: [NowPlayableCommand] {
        [
            .togglePausePlay,
            .play,
            .pause,
            .nextTrack,
            .like,
            .dislike,
        ]
    }
    
    var defaultDisabledCommands: [NowPlayableCommand] {
        []
    }
    
    func handleNowPlayableConfiguration(
            commands: [NowPlayableCommand],
            disabledCommands: [NowPlayableCommand],
            commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus,
            interruptionHandler: @escaping (NowPlayableInterruption) -> Void) throws {
        try configureRemoteCommands(commands, disabledCommands: disabledCommands, commandHandler: commandHandler)
    }
    
    func handleNowPlayableSessionStart() {
        MPNowPlayingInfoCenter.default().playbackState = .paused
    }
    
    func handleNowPlayableSessionEnd() {
        MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
    
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata) {
        setNowPlayingMetadata(metadata)
    }
    
    func handleNowPlayablePlaybackChange(playing isPlaying: Bool, metadata: NowPlayableDynamicMetadata) {
        setNowPlayingPlaybackInfo(metadata)
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
    }
}
