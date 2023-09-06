//
//  DataPersistenceManager.swift
//  NetfilxClone
//
//  Created by tungdd on 07/07/2023.
//

import UIKit
import CoreData
enum DatabaseError: Error {
    case failedToSaveData
    case failedToFetchData
}

class DataPersistenceManager {
    static let SHARED = DataPersistenceManager()
    
    func download(model: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext

        let item = MovieItem(context: context)
        item.id = Int64(model.id)
        item.original_language = model.original_language
        item.original_title = model.original_title
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.release_date = model.release_date

        do {
            try context.save()
            completion(.success(()))
        }
        catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func fetchingMoviesFromDatabase(completion: @escaping(Result<[MovieItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<MovieItem>
        request = MovieItem.fetchRequest()
        
        do {
            let movies = try context.fetch(request)
            completion(.success(movies))
        }
        catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func delete(indexPath: IndexPath,completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<MovieItem>
        request = MovieItem.fetchRequest()
        do {
            let movies = try context.fetch(request)
            context.delete(movies[indexPath.row])
            try context.save()
            completion(.success(()))
        }
        catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
}


