import Foundation

/// Handles events sent from pianobar per the Eventcmd section at https://linux.die.net/man/1/pianobar
class HandlePianobarEvent: NSScriptCommand {
    
    override func performDefaultImplementation() -> Any? {
        guard let eventName = evaluatedArguments?["eventName"] as? String,
              let eventData = evaluatedArguments?["eventData"] as? String else {
            NSLog("Missing eventName or eventData")
            return nil
        }
        
        NSLog("Received event name from pianobar: \(eventName)")
        NSLog("Received event data from pianobar:\n\(eventData)")
        
        // "The Game Has Changed (From "TRON: Legacy"/Score)" by "Daft Punk" on "TRON: Legacy"
        // 226:230: syntax error: Expected end of line but found identifier. (-2741)
        // https://www.pandora.com/artist/daft-punk/tron-legacy/the-game-has-changed-from-tron-legacy-score/TR4ljvPcbxfb6qk
        /**
         artist=The Glitch Mob
         title=Bad Wings X Skullclub (revision)
         album=Revisions
         coverArt=http://mediaserver-cont-usc-mp1-2-v4v6.pandora.com/images/9e/f4/2f/71/1af94446bb248907ef8ff7aa/1080W_1080H.jpg
         stationName=The Glitch Mob Radio
         songStationName=
         pRet=1
         pRetStr=Everything is fine :)
         wRet=0
         wRetStr=No error
         songDuration=0
         songPlayed=0
         rating=0
         detailUrl=http://www.pandora.com/glitch-mob/revisions/bad-wings-x-skullclub-revision/TR5g6tfVpJrxt9Z?dc=63626&ad=1:26:1:06712::0:0:0:0:533::CT:09009:2:0:0:0:0:0
         */
        /**
         you passed me songstart
         artist=Blue Stahli title=Command Line Kill album=Quartz (Explicit) coverArt=http://mediaserver-cont-dc6-1-v4v6.pandora.com/images/78/8c/26/72/f34141f3844ba80b3f186523/1080W_1080H.jpg stationName=The Glitch Mob Radio songStationName= pRet=1 pRetStr=Everything is fine :) wRet=0 wRetStr=No error songDuration=146 songPlayed=0 rating=0 detailUrl=http://www.pandora.com/blue-stahli/quartz-explicit/command-line-kill/TRq4c5t27qdmcjg?dc=63626&ad=1:26:1:06712::0:0:0:0:533::CT:09009:2:0:0:0:0:0 stationCount=43 station0=Adventure Club Radio station1=Akon Radio station2=Alan Walker Radio station3=Bebe Rexha Radio station4=BTS (K-Pop) Radio station5=Dj Manian Radio station6=Dubstep Radio station7=EDM Hits Radio station8=Eminem Radio station9=Glass Animals Radio station10=Green Day Radio station11=Handlebars Radio station12=ItaloBrothers Radio station13=K-391 Radio station14=Kane Brown Radio station15=Klaas Radio station16=Klaypex Radio station17=Linkin Park Radio station18=Logic & Marshmello Radio station19=Losing My Mind Radio station20=Lost Stories Radio station21=Love & War (Feat. Yade Lauren) Radio station22=LSD Radio station23=marshmello Radio station24=Martin Garrix Radio station25=Mitis Radio station26=NEFFEX Radio station27=Nelly & Florida Georgia Line Radio station28=New K-Pop Radio station29=Pop and Hip Hop Power Workout Radio station30=Proximity Radio station31=QuickMix station32=Seesaw Radio station33=Seven Lions Radio station34=Señorita Radio station35=The Chainsmokers Radio station36=The Glitch Mob Radio station37=Three Days Grace Radio station38=Thumbprint Radio station39=Today's Country Radio station40=Today's Hits Radio station41=Trap and Dubstep Hits Radio station42=Zedd Radio
         */
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
