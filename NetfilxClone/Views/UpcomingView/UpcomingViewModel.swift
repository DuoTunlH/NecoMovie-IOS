//
//  UpcomingViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import Combine

class UpcomingViewModel {

    var movies = CurrentValueSubject<[Movie],Never>([])
    private let output = PassthroughSubject<Output,Never>()
    private var cancellables = Set<AnyCancellable>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output,Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            }
            
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func fetchData() {
        APICaller.shared.getMovies(type: "movie", status: "upcoming") { results in
            switch results{
            case .success(let movies):
                self.movies.value = movies
                self.output.send(.fetchDidSucceed)
            case .failure(let error):
                print(String(describing: error))
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
