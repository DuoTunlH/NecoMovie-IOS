//
//  MovieDetailViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class MovieDetailViewModel {
    
    var movieTrailers = [Video]()
    var movie: Movie? = nil
    var similarMovies = [Movie]()
    var output = PassthroughSubject<Output, Never>()
    var isFavourite = false
    private var cancellables = Set<AnyCancellable>()
    var db = Firestore.firestore()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
            case .addToFavourite:
                self?.addToFavourite()
            case .removeFromFavourite:
                self?.removeFromFavourite()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    func fetchData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        APICaller.shared.getVideos(movieId: (self.movie?.id) ?? 0) { [unowned self]
            results in
            defer {
                dispatchGroup.leave()
            }
            switch results{
            case .success(let videos):
                self.movieTrailers = videos
            case .failure(let error):
                self.output.send(.fetchDidFail(error: error))
            }
        }

        dispatchGroup.enter()
        APICaller.shared.getMovies(type: "movie", status: String(movie!.id), time: "similar") {
            [unowned self] results in
            defer {
                dispatchGroup.leave()
            }
            switch results{
            case .success(let movies):
                self.similarMovies = movies
            case .failure(let error):
                self.output.send(.fetchDidFail(error: error))
            }
        }
        dispatchGroup.enter()
        db.collection(Auth.auth().currentUser!.uid).whereField("id", isEqualTo: movie!.id).getDocuments {
            (querySnapshot,error) in
            defer {
                dispatchGroup.leave()
            }
            if let error = error {
                self.output.send(.fetchDidFail(error: error))
            }
            if !querySnapshot!.isEmpty {
                self.isFavourite = true
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.output.send(.fetchDidSucceed)
        }
    }
    
    func addToFavourite() {
        db.collection(Auth.auth().currentUser!.uid).addDocument(data: [
            "id": movie?.id ?? 0,
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.isFavourite = true
                self.output.send(.fetchDidSucceed)
//                NotificationCenter.default.post(name: Notification.Name("addToFavourite"), object: self.movie)
            }
        }
    }
    
    func removeFromFavourite() {
        isFavourite = false
        self.output.send(.fetchDidSucceed)
        NotificationCenter.default.post(name: Notification.Name("removeFromFavourite"), object: self.movie!.id)
    }
    enum Input {
        case viewDidLoad
        case addToFavourite
        case removeFromFavourite
    }
    enum Output {
        case fetchDidFail(error: Error)
        case fetchDidSucceed
    }
}
