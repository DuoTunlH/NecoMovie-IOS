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
    private var cancellables = Set<AnyCancellable>()
    var db = Firestore.firestore()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchData()
                self?.checkFavourite()
            case .addToFavourite:
                self?.addToFavourite()
            case .removeFromFavourite:
                self?.removeFromFavourite()
            default:
                break
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
                self.output.send(.isFavourite(result: true))
                NotificationCenter.default.post(name: Notification.Name("addToFavourite"), object: self.movie)
            }
        }
    }
    
    func checkFavourite() {
        db.collection(Auth.auth().currentUser!.uid).whereField("id", isEqualTo: movie!.id).getDocuments {
            (querySnapshot,error) in
            if let error = error {
                self.output.send(.fetchDidFail(error: error))
            }
            !querySnapshot!.isEmpty ?
            self.output.send(.isFavourite(result: true)) : self.output.send(.isFavourite(result: false))
        }
    }
    
    func removeFromFavourite() {
        db.collection(Auth.auth().currentUser!.uid).whereField("id", isEqualTo: movie!.id).getDocuments {
            (querySnapshot,error) in
            if let error = error {
                self.output.send(.fetchDidFail(error: error))
            }
            for document in querySnapshot!.documents {
                self.db.collection(Auth.auth().currentUser!.uid).document(document.documentID).delete()
            }
            self.output.send(.isFavourite(result: false))
            NotificationCenter.default.post(name: Notification.Name("removeFromFavourite"), object: self.movie!.id)
        }
    }
    enum Input {
        case viewDidLoad
        case addToFavourite
        case removeFromFavourite
    }
    enum Output {
        case fetchDidFail(error: Error)
        case fetchDidSucceed
        case isFavourite(result: Bool)
    }
}
