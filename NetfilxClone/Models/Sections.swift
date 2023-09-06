//
//  Sections.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation

enum Sections:String, CaseIterable {
    
    case Trending
    case Popular
    case Upcoming
    case TopRated
    case Action
    case Adventure
    case Animation
    case Comedy
    case Crime
    case Drama
    case Family
    case Fantasy
    case History
    case Horror
    case ScienceFiction
    
    var title: String {
        switch self {
        case .TopRated:
            return "Top Rated"
        case .ScienceFiction:
            return "Science Fiction"
        default:
            return self.rawValue
        }
    }
    
    var type: String {
        switch self{
        case .Trending:
            return "trending"
        case .Upcoming, .TopRated, .Popular:
            return "movie"
        default:
            return "discover"
        }
    }
    
    var status : String {
        switch self {
        case .Trending:
            return "movie"
        case .Popular:
            return "popular"
        case .Upcoming:
            return "upcoming"
        case .TopRated:
            return "top_rated"
        default:
            return "movie"
        }
    }
    
    var time: String {
        switch self {
        case .Trending:
            return "day"
        default:
            return ""
        }
    }
    
    var index: Int {
        return Sections.allCases.firstIndex(of: self)!
    }
    
    var genreId: String {
        switch self {
        case .Trending, .Upcoming, .TopRated, .Popular:
            return ""
        case .Action:
            return "28"
        case .Adventure:
            return "12"
        case .Animation:
            return "16"
        case .Comedy:
            return "35"
        case .Crime:
            return "80"
        case .Drama:
            return "18"
        case .Family:
            return "10751"
        case .Fantasy:
            return "14"
        case .History:
            return "36"
        case .Horror:
            return "27"
        case .ScienceFiction:
            return "878"
        }
    }
}
