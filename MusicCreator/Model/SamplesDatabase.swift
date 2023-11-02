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
    func getSample(instrument: MusicInstrument, index: Int) -> URL?
}

class SoundsDatabase: SamplesDatabase {
    private lazy var availableSounds: Dictionary<MusicInstrument, [URL]> = loadFromLocal()

    func getSample(instrument: MusicInstrument, index: Int) -> URL? {
        guard let sounds = availableSounds[instrument],
              index < sounds.count
        else { return nil }

        return sounds[index]
    }

    private func loadFromLocal() -> Dictionary<MusicInstrument, [URL]> {
        var sounds = Dictionary<MusicInstrument, [URL]>()

        let guitarSounds = ["GuitarChordLoop", "GuitarMelodyLoop", "GuitarMoonlightLoop"].compactMap ({ Bundle.main.url(forResource: $0, withExtension: "wav") })
        let drumsSounds = ["DrumsFutureLoop", "DrumsHeaterLoop", "DrumsTitanLoop"].compactMap({ Bundle.main.url(forResource: $0, withExtension: "wav") })
        let windSounds = ["WindEmpireMelody1", "WindEmpireMelody2", "WindEmpireMelody3"].compactMap({ Bundle.main.url(forResource: $0, withExtension: "wav") })

        sounds[.guitar] = guitarSounds
        sounds[.drums] = drumsSounds
        sounds[.wind] = windSounds

        return sounds
    }
}
