//
//  Video.swift
//  NetfilxClone
//
//  Created by tungdd on 30/06/2023.
//

import Foundation


class Video: Codable {
    var key: String?
    var type: String?
    var published_at: String?
}

class VideoResponse: Codable {
    let results: [Video]
}
