//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by Poseidon Ho on 1/29/16.
//  Copyright © 2016 oi7. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    // Image view that will contain the memed image
    @IBOutlet weak var imageView: UIImageView!
    
    var memeIndex: Int!
    var meme: Meme!
    
    // MARK: -
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme(sender:)))
        imageView?.image = meme.memedImage as UIImage
        imageView.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: -
    // MARK: Actions
    
    @IBAction func deleteMeme(sender: UIButton) {
        MemeManager.shared.deleteMemeAtIndex(index: memeIndex)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func editMeme(sender: UIBarButtonItem) {
        let memeEditorController = storyboard!.instantiateViewController(withIdentifier: "MemeEditor") as! MemeEditorViewController
        memeEditorController.meme = meme
        present(memeEditorController, animated: true, completion: nil)
    }
}
