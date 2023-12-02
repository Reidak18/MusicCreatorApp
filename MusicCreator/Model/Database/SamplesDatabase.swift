//
//  SamplesDatabase.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 02.11.2023.
//

import Foundation

enum MusicInstrument {
    case guitar
    case drums
    case wind
}

protocol SamplesDatabaseProtocol: AnyObject {
    func getSamples() -> Dictionary<MusicInstrument, [String]>
    func getSample(instrument: MusicInstrument, index: Int) -> AudioSample?
}

class SamplesDatabase: SamplesDatabaseProtocol {
    private var sounds: Dictionary<MusicInstrument, [String]> = [:]

    init() {
        loadFromLocal()
    }

    private func loadFromLocal() {
        sounds[.guitar] = ["Guitar-riff",
                           "Violin",
                           "Guitar-loop"]
        sounds[.drums] = ["Hihats",
                          "Kick",
                          "Snare"]
        sounds[.wind] = ["Bieber-style",
                         "Pan-flute",
                         "Flute-hammer"]
    }

    func getSamples() -> Dictionary<MusicInstrument, [String]> {
        return sounds
    }

    func getSample(instrument: MusicInstrument, index: Int) -> AudioSample? {
        guard let instrumentSounds = sounds[instrument],
              index < sounds.count
        else {
            return nil }

        return createAudioSample(instrumentSounds[index], instrument)
    }

    private func createAudioSample(_ fileName: String, _ type: MusicInstrument) -> AudioSample? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav")
        else { return nil }

        return AudioSample(name: fileName, audioUrl: url, imageName: fileName)
    }
}
