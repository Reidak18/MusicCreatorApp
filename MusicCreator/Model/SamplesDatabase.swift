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

protocol SamplesDatabase {
    func getSample(instrument: MusicInstrument, index: Int) -> AudioSample?
}

class SoundsDatabase: SamplesDatabase {
    private lazy var availableSounds: Dictionary<MusicInstrument, [AudioSample]> = loadFromLocal()

    func getSample(instrument: MusicInstrument, index: Int) -> AudioSample? {
        guard let sounds = availableSounds[instrument],
              index < sounds.count
        else { return nil }

        return sounds[index]
    }

    private func loadFromLocal() -> Dictionary<MusicInstrument, [AudioSample]> {
        var sounds = Dictionary<MusicInstrument, [AudioSample]>()

        sounds[.guitar] = ["Electric",
                           "Goldkind",
                           "Kaponja"].enumerated().compactMap({ createAudioSample($0.element, $0.offset, .guitar) })
        sounds[.drums] = ["Hihats",
                          "Kick",
                          "Snare"].enumerated().compactMap({ createAudioSample($0.element, $0.offset, .drums) })
        sounds[.wind] = ["FluteA4",
                         "FluteD2",
                         "FluteF3"].enumerated().compactMap({ createAudioSample($0.element, $0.offset, .wind) })

        return sounds
    }

    private func createAudioSample(_ fileName: String, _ index: Int, _ type: MusicInstrument) -> AudioSample? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav")
        else { return nil }

        var name = ""
        switch type {
        case .guitar:
            name = "Гитара \(index + 1)"
        case .drums:
            name = "Ударные \(index + 1)"
        case .wind:
            name = "Духовые \(index + 1)"
        }

        return AudioSample(name: name, audioUrl: url)
    }
}
