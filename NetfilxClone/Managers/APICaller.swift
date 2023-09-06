//
//  APICaller.swift
//  NetfilxClone
//
//  Created by tungdd on 27/06/2023.
//

import Foundation

struct Constants {
    static let API_KEY = "f14dabb7ec91ad6abc33ee277d4c4d07"
    static let BASE_URL = "https://api.themoviedb.org"
}

class APICaller {
    static let shared = APICaller()
    
    func getMovies(type: String,status: String, time: String?  = "", query: String = "", page: Int = 1, genre: String = "", completion: @escaping (Result<[Movie], Error>) -> Void) {
        var tempTime: String? = ""
        if time != ""{
            tempTime = "/" + time!
        }
        let url = "\(Constants.BASE_URL)/3/\(type)/\(status)\(tempTime!)?api_key=\(Constants.API_KEY)\("&query=" + query)&page=\(page)&with_genres=\(genre)"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let newUrl = URL(string: urlString!)
        let task = URLSession.shared.dataTask(with: URLRequest(url: newUrl!)) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return}
            do {
                let results = try JSONDecoder().decode(MoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(results.results))
                }
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getMovieByID(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let url = URL(string: "\(Constants.BASE_URL)/3/movie/\(id)?api_key=\(Constants.API_KEY)")
        let task = URLSession.shared.dataTask(with: URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData)) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return}
            do {
                let results = try JSONDecoder().decode(Movie.self, from: data)
                DispatchQueue.main.async {              
                    completion(.success(results))
                }
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getVideos(movieId: Int, completion: @escaping (Result<[Video],Error>) -> Void) {
        let url = "\(Constants.BASE_URL)/3/movie/\(movieId)/videos?api_key=\(Constants.API_KEY)"
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalCacheData)) {
            data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return}
            do {
                let results = try JSONDecoder().decode(VideoResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(results.results))
                }
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}

