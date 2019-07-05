//
//  Transfer.swift
//  Look Roulette
//
//  Created by Cortland Walker on 7/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

class Transfer: Codable {
    
    var videoId: String
    var baseImage: String
    var lookImage: String
    var resultImage: String
    
    
    init(videoId: String, baseImage: String, lookImage: String, resultImage: String) {
        self.videoId     = videoId
        self.baseImage   = baseImage
        self.lookImage   = lookImage
        self.resultImage = resultImage
    }
}
