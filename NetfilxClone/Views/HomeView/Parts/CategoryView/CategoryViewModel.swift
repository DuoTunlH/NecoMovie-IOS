//
//  File.swift
//  NetfilxClone
//
//  Created by tungdd on 09/08/2023.
//

import Foundation
import Combine

class CategoryViewModel {
    var cancellables = Set<AnyCancellable>()
    var output = PassthroughSubject<Output, Never>()
    var movies = [Movie]()
    var section: Sections
    var isLoading = false
    var page = 0
    
    init(section: Sections) {
        self.section = section
    }
    
    func transform(input: AnyPublisher<Input,Never>) -> AnyPublisher<Output,Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func fetchData() {
        if !self.isLoading {
            page += 1
            isLoading = true
            APICaller.shared.getMovies(type: section.type,status: section.status, time: section.time,page: page, genre: section.genreId)
            { results in
                switch results {
                case .success(let movies):
                    self.movies += movies
                    self.isLoading = false
                    self.output.send(.fetchDidSucceed)
                case .failure(let error):
                    self.output.send(.fetchDidFail(error: error))
                }
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
