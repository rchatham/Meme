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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editMeme:")
        imageView?.image = meme.memedImage as UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: -
    // MARK: Actions
    
    @IBAction func deleteMeme(sender: UIButton) {
        MemeManager.sharedInstance.deleteMemeAtIndex(memeIndex)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func editMeme(sender: UIBarButtonItem) {
        let memeEditorController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        memeEditorController.meme = meme
        presentViewController(memeEditorController, animated: true, completion: nil)
    }
}