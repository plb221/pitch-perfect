//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Paul Bruno on 3/28/15.
//  Copyright (c) 2015 Emergent Ink. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    init (filePathUrl: NSURL) {
        self.filePathUrl = filePathUrl
        self.title = filePathUrl.lastPathComponent
    }
}