//
//  TwitterModel.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 30.11.2023.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let twitterModel = try? JSONDecoder().decode(TwitterModel.self, from: jsonData)

import Foundation

// MARK: - TwitterModel
struct TwitterMediaModel: Codable {
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let tweetResult: TweetResult?
}

// MARK: - TweetResult
struct TweetResult: Codable {
    let result: Result?
}

// MARK: - Result
struct Result: Codable {
    let legacy: Legacy?
}

// MARK: - Legacy
struct Legacy: Codable {
    let entities: Entities?
    let fullText: String?

    enum CodingKeys: String, CodingKey {
        case entities
        case fullText = "full_text"
    }
}

// MARK: - Entities
struct Entities: Codable {
    let media: [Media]?
}

// MARK: - Media
struct Media: Codable {
    let displayURL: String?
    let expandedURL: String?
    let mediaURLHTTPS: String?
    let type: String?
    let url: String?
    let videoInfo: VideoInfo?

    enum CodingKeys: String, CodingKey {
        case displayURL = "display_url"
        case expandedURL = "expanded_url"
        case mediaURLHTTPS = "media_url_https"
        case type, url
        case videoInfo = "video_info"
    }
}

// MARK: - VideoInfo
struct VideoInfo: Codable {
    let aspectRatio: [Int]?
    let durationMillis: Int?
    let variants: [Variant]?

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case durationMillis = "duration_millis"
        case variants
    }
}

// MARK: - Variant
struct Variant: Codable {
    let contentType: String?
    let url: String?
    let bitrate: Int?

    enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case url, bitrate
    }
}


