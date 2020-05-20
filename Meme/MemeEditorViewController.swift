//
//  MemeEditorViewController.swift
//  Meme
//
//  Created by Poseidon Ho on 1/27/16.
//  Copyright © 2016 oi7. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Meme text and image
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // Top bar
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Bottom bar
    @IBOutlet weak var toolBar: UIToolbar!
    
    // Existing meme reference. Used only when the editor will edit an existing meme
    var meme: Meme?
    
    
    // MARK: -
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let existingMeme = meme {
            // Existing meme. Use self.meme
            setupTextField(string: existingMeme.top, textField: topTextField)
            setupTextField(string: existingMeme.bottom, textField: bottomTextField)
            imageView.image = existingMeme.image
            shareButton.isEnabled = true
        } else {
            // New meme. self.meme is not used
            setupTextField(string: "TOP", textField: topTextField)
            setupTextField(string: "BOTTOM", textField: bottomTextField)
            shareButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Enable the camera button if is supported by the device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: -
    // MARK: NSNotification subscriptions and selectors
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification: notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: -
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // When a user taps inside a textfield, the default text should clear.
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // When a user presses return, the keyboard should be dismissed
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: -
    // MARK: UIImagePickerControllerDelegate
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = originalImage
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            // Enable share button now that we have an image
            shareButton.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    // MARK: Actions
    
    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        //  generate a memed image
        let memedImage = generateMemedImage()
        
        // define an instance of the ActivityViewController
        // pass the ActivityViewController a memedImage as an activity item
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        activity.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> Void in
            if completed {
                // Save meme and dismiss
                self.saveMeme(memedImage: memedImage)
                activity.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }

        // present the ActivityViewController
        present(activity, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        presentImagePickerOfType(sourceType: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        presentImagePickerOfType(sourceType: .camera)
    }
    
    // MARK: -
    // MARK: Utility methods
    
    // Setup Text filed to approximate to the "Impact" font, all caps, white with a black outline
    func setupTextField(string: String, textField: UITextField) {
        let memeTextAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth : -3
            ] as [NSAttributedStringKey : Any]


        let attributedString = NSAttributedString(string: string, attributes: memeTextAttributes)
        textField.attributedText = attributedString
//        textField.defaultTextAttributes = memeTextAttributes
        // Text should be center-aligned
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    // Present the image picker depending on the specified sourceType
    func presentImagePickerOfType(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func toolbarVisible(visible: Bool) {
        toolBar.isHidden = !visible
        navigationBar.isHidden = !visible
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbar
        toolbarVisible(visible: false)
        
        // Render view to image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar
        toolbarVisible(visible: true)
        
        return memedImage
    }
    
    // Saves the meme correctly. Is the meme is new it saves a new one in the shared model
    // If the meme already exists the method only updates its values
    func saveMeme(memedImage: UIImage) {
        if var existingMeme = meme {
            // Meme exists. Just change its existing properties
            existingMeme.top = topTextField.text!
            existingMeme.bottom = bottomTextField.text!
            existingMeme.image = imageView.image!
            existingMeme.memedImage = memedImage
        } else {
            // New meme. Create one and add it to the sahred model
            let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
            // Add the saved meme to the shared model
            MemeManager.shared.appendMeme(meme: meme)
        }
    }
}
