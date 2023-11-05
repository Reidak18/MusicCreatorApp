//
//  DatabaseFactory.swift
//  MusicCreator
//
//  Created by Nikita Lukyantsev on 05.11.2023.
//

import Foundation

protocol SamplesDatabaseFactoryProtocol {
    func getDatabase() -> SamplesDatabaseProtocol
}

class SamplesDatabaseFactory: SamplesDatabaseFactoryProtocol {
    func getDatabase() -> SamplesDatabaseProtocol {
        return SamplesDatabase()
    }
}
