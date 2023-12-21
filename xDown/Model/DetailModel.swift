//
//  DetailModel.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 21.12.2023.
//

import Foundation

struct DetailModel: Identifiable {
    var id: Int
    var type: DetailMediaType
    var backgroundImageUrl: String
    var video: [DetailVideoModel] = []
}

enum DetailMediaType {
    case none
    case video
    case gif
    case photo
}

struct DetailVideoModel {
    var url: String
    var quality: String
}

