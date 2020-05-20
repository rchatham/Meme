//
//  MemeTableViewController.swift
//  Meme
//
//  Created by Poseidon Ho on 1/24/16.
//  Copyright © 2016 oi7. All rights reserved.
//

import Foundation
import UIKit

// Table view for the sent memes
class MemeTableViewController: UITableViewController {
    
    // This is a flag used to identify if the meme editor was shown only the first time.
    // The problem araises when the user cancels the editor but doesn't have at least one
    // sent meme. In this situation the viewWillAppear method (whitout the flag) presents
    // the meme editor again, creating a "bounce" effect between the editor and the
    // sent meme list.
    var editorNotPresented = true
    
    var memes: [Meme]!
    
    // MARK: -
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the edit buttom in the navigation bar
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh the local memes
        memes = MemeManager.shared.memes
        // Refresh the table list
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The editor should be presented if there are no sent memes
        if memes.count == 0 && editorNotPresented {
            editorNotPresented = false
            // No memes. Lets present the editor
            presentCleanMemeEditor()
        }
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell") as! MemeTableViewCell
        
        let meme = memes[indexPath.row]
        
        cell.memeImageView.image = meme.memedImage
        cell.memeLabel.text = buildMemeTextSummary(meme: meme)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            removeMemeAtIndexPath(indexPath: indexPath)
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: -
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Edit action
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler: { (action, indexPath) -> Void in
            let meme = self.memes[indexPath.row]
            self.presentMemeEditor(meme: meme)
        })
        // Delete action
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action, indexPath) -> Void in
            self.removeMemeAtIndexPath(indexPath: indexPath)
        })
        
        let arrayofactions: Array = [delete, edit]
        
        return arrayofactions
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        
        let destinationController = storyboard?.instantiateViewController(withIdentifier: "MemeDetail") as! MemeDetailViewController
        destinationController.meme = meme
        destinationController.memeIndex = indexPath.row
        
        navigationController?.pushViewController(destinationController, animated: true)
    }
    
    // MARK: -
    // MARK: Actions
    
    @IBAction func createMeme(sender: UIBarButtonItem) {
        presentCleanMemeEditor()
    }
    
    // MARK: -
    // MARK: Utilities
    
    // Presents the editor without an existing meme
    // This is just a wrapper method for better readability
    func presentCleanMemeEditor() {
        presentMemeEditor(meme: nil)
    }
    
    // Correclty removes the meme from the model and the table
    func removeMemeAtIndexPath(indexPath: IndexPath) {
        // remove the deleted item from the model
        MemeManager.shared.deleteMemeAtIndex(index: indexPath.row)
        memes = MemeManager.shared.memes
        // remove the deleted item from the `UITableView`
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // Presents the meme editor. Uses a existing meme if is provided as a parameter
    func presentMemeEditor(meme: Meme?) {
        let memeEditorController = storyboard!.instantiateViewController(withIdentifier: "MemeEditor") as! MemeEditorViewController
        if let existingMeme = meme {
            memeEditorController.meme = existingMeme
        }
        present(memeEditorController, animated: true, completion: nil)
    }
    
    // Creates a string to display as the meme summary in a cell
    func buildMemeTextSummary(meme: Meme) -> String {
//        let topCount = meme.top.count
//        let bottomCount = meme.bottom.count
        
        let topSubstring = meme.top
        let bottomSubstring = meme.bottom
        
        return "\(topSubstring). \(bottomSubstring)"
    }
    
}
