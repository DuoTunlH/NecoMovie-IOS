//
//  HomeViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import Combine

class HomeViewModel {
    
    var moviesForSections = [(Sections,[Movie])]()
    var sections = Sections.allCases
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func fetchData() {
        let dispatchGroup = DispatchGroup()
        var isFalure = false
        Sections.allCases.forEach { section in
            dispatchGroup.enter()
            APICaller.shared.getMovies(type: section.type,status: section.status, time: section.time, genre: section.genreId)
            { results in
                defer {
                    dispatchGroup.leave()
                }
                switch results {
                case .success(let movies):
                    self.moviesForSections.append((section, movies))
                case .failure(let error):
                    self.output.send(.fetchDidFail(error: error))
                    isFalure = true
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !isFalure {
                self.output.send(.fetchDidSucceed)
            }
        }
    }
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case fetchDidFail(error: Error)
        case fetchDidSucceed
    }
}
