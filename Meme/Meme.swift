//
//  Meme.swift
//  Meme
//
//  Created by Poseidon Ho on 1/27/16.
//  Copyright © 2016 oi7. All rights reserved.
//

import Foundation
import UIKit

// Class tha represents a meme with a image, top and bottom texts
class Meme: NSObject {
    
    // Meme elements
    var top: String
    var bottom: String
    var image: UIImage
    
    // The actual meme image. It was built using the meme elemets
    var memedImage: UIImage
    
    init(top: String, bottom: String, image: UIImage, memedImage: UIImage) {
        self.top = top
        self.bottom = bottom
        self.image = image
        self.memedImage = memedImage
    }
}