//
//  SearchViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import Combine



class SearchViewModel {
    private let output  = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    var searchingMovies = CurrentValueSubject<[Movie],Never>([])
    var discoveryMovies = CurrentValueSubject<[Movie],Never>([])
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            default: break
            }
        }.store(in: &cancellables)
        
        input
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .isSearching(let searchText):
                self?.fetchSearching(searchText: searchText)
            default: break
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        APICaller.shared.getMovies(type: "discover", status: "movie") { results in
            switch results{
            case .success(let movies):
                self.discoveryMovies.value = movies
                self.output.send(.fetchDidSucceed)
            case .failure(let error):
                self.output.send(.fetchDidFail(error: error))
            }
        }
    }
    
    private func fetchSearching(searchText: String) {
            APICaller.shared.getMovies(type: "search", status: "movie", query: searchText) { results in
                switch results{
                case .success(let movies):
                    self.searchingMovies.value = movies
                    self.output.send(.fetchDidSucceed)
                case .failure(let error):
                    self.output.send(.fetchDidFail(error: error))
                }
            }
    }
    
    enum Input {
        case viewDidLoad
        case isSearching(searchText: String)
    }
    enum Output {
        case fetchDidFail(error: Error)
        case fetchDidSucceed
    }
}
