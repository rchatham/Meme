//
//  MemeManager.swift
//  Meme
//
//  Created by Poseidon Ho on 1/29/16.
//  Copyright © 2016 oi7. All rights reserved.
//

import Foundation

class MemeManager: NSObject {

    static var shared: MemeManager = MemeManager()
    
    // Shared model representing the list of sent memes
    var memes = [Meme]()
    
    func deleteMemeAtIndex(index: Int) {
        memes.remove(at: index)
    }
    
    func appendMeme(meme: Meme) {
        memes.append(meme)
    }
}
