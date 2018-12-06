//
//  DetailViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 11/29/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DetailViewController: UIViewController {
    var books: [Book] = []
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    
    let image = UIImage(named: "camera.png")
    
    func configureView() {
        if let detail = detailItem {
            if let label = titleLabel {
                label.text = detail.title
            }
            if let label = authorLabel {
                label.text = detail.author
            }
            if let label = ratingLabel {
                label.textColor = UIColor.green
                label.text = "Rating: " + detail.rating! + " / 5"
            }
            if let label = releaseYearLabel {
                label.textColor = UIColor.green
                label.text = "Release year: " + detail.releaseYear!
            }
            /*if let imageView = self.imageView {
                //(image: UIImage?) in
                imageView.image = image
            }*/
        }
    }
    @IBAction func photoClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toPhotoViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "toPhotoViewController" {
            guard segue.destination is AttachPhotoViewController else {
                return
            }
        }*/
        showAlert()
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //get image from source type
    func getImage(fromSourceType sourceType: UIImagePickerControllerSourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            //imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        photoButton.setImage(image, for: .normal)
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Book? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
}
