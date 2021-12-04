import Foundation

/// Handles events sent from pianobar per the Eventcmd section at https://linux.die.net/man/1/pianobar
class HandlePianobarEvent: NSScriptCommand {
    
    override func performDefaultImplementation() -> Any? {
        guard let eventName = evaluatedArguments?["eventName"] as? String,
              let eventData = evaluatedArguments?["eventData"] as? String else {
            NSLog("Missing eventName or eventData")
            return nil
        }
        
        NSLog("Received event from pianobar: \(eventName)")
        
        let eventDataDictionary = eventData
                .split(whereSeparator: \.isNewline)
                .reduce(into: [String: String]()) { result, keyValueString in
                    let keyValue = keyValueString.split(separator: "=", maxSplits: 1)
                    result[String(keyValue[0])] = keyValue.count == 1 ? "" : String(keyValue[1])
                }
        
        if (eventName == "songstart") {
            NSLog("Handling event from pianobar: \(eventName)")
            PianobarPlayer.shared?.setNowPlayingInformation(
                    title: eventDataDictionary["title"] ?? "N/A",
                    artist: eventDataDictionary["artist"] ?? "N/A",
                    album: eventDataDictionary["album"] ?? "N/A",
                    albumArtUrl: eventDataDictionary["coverArt"] ?? "")
        }
        return nil
    }
}
