//
//  DownloadViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class FavouriteViewModel {
    
    var movies = [Movie]()
    var cancellables = Set<AnyCancellable>()
    var output = PassthroughSubject<Output, Never>()
    var db = Firestore.firestore()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            case .delete(let id):
                self?.delete(id: id)            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func fetchData() {
        db.collection(Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let dispatchGroup = DispatchGroup()
                var isFailure = false
                var tempMovies = [Movie]()
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    self.output.send(.fetchDidSucceed)
                    APICaller.shared.getMovieByID(id: document.data().values.first as! Int) { results in
                        defer {
                            dispatchGroup.leave()
                        }
                        switch results{
                        case .success(let movie):
                            tempMovies.append(movie)
                        case .failure(let error):
                            self.output.send(.fetchDidFail(error: error))
                            isFailure = true
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    if !isFailure {
                        self.movies = tempMovies
                        self.output.send(.fetchDidSucceed)
                    }
                }
            }
        }
    }
    
    func delete(id: Int) {
        self.movies = movies.filter {
            $0.id != id
        }
        self.output.send(.fetchDidSucceed)
    }
    enum Input {
        case viewDidLoad
        case delete(id: Int)
    }
    enum Output {
        case fetchDidFail(error: Error)
        case fetchDidSucceed
    }
}
