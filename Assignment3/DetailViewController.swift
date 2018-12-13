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

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var books: [Book] = []
    var managedObjectContext: NSManagedObjectContext? = nil

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var ratingImageStars: UIImageView!
    @IBOutlet weak var findBookButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    func configureView() {
        
        if let detail = detailItem {
            let ratingInt = Int(detail.rating!)
            if let label = titleLabel {
                label.text = detail.title
            }
            if let label = authorLabel {
                label.text = detail.author
            }
            if let label = ratingLabel {
                label.text = "Rating: " // + detail.rating! + " / 5"
                
                //Comment this code out if the starts are not going to be used and remove the stars ImageView in the storyboard.
                
                /*if ratingInt! == 1 {
                    label.textColor = UIColor.red
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                } else if ratingInt! == 2  {
                    label.textColor = UIColor.darkGray
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                } else if ratingInt! == 3  {
                    label.textColor = UIColor.brown
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                } else if ratingInt! == 4  {
                    label.textColor = UIColor.purple
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                } else if ratingInt! == 5 {
                    label.textColor = UIColor.green
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                } else {
                    label.textColor = UIColor.orange
                    label.someTextColorChange(fullText: label.text!, changeText: "Rating: ")
                }*/
            }
            if let label = releaseYearLabel {
                let yearInt = Int(detail.releaseYear!)
                label.text = "Release Year: " + detail.releaseYear!
                if yearInt! < 1989 {
                    label.textColor = UIColor.darkGray
                    label.someTextColorChange(fullText: label.text!, changeText: "Release Year: ")
                } else if yearInt! >= 1989 && yearInt! < 1999  {
                    label.textColor = UIColor.brown
                    label.someTextColorChange(fullText: label.text!, changeText: "Release Year: ")
                } else if yearInt! >= 1999 && yearInt! < 2010 {
                    label.textColor = UIColor.purple
                    label.someTextColorChange(fullText: label.text!, changeText: "Release Year: ")
                } else if yearInt! >= 2010 && yearInt! < 2017 {
                    label.textColor = UIColor.green
                    label.someTextColorChange(fullText: label.text!, changeText: "Release Year: ")
                } else {
                    label.textColor = UIColor.orange
                    label.someTextColorChange(fullText: label.text!, changeText: "Release Year: ")
                }
            }
            if let imageView = self.imageView {
                // (image: UIImage?) in
                if let image = detail.image {
                    imageView.image = UIImage(data: image as Data)
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderWidth = 2
                    imageView.layer.borderColor = UIColor.lightGray.cgColor
                } else {
                    imageView.image = UIImage(named: "book")
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderWidth = 2
                    imageView.layer.borderColor = UIColor.lightGray.cgColor
                }
            }
            if let ratingImageStars = self.ratingImageStars {
                ratingImageStars.image = UIImage(named:"\(ratingInt!)Stars")
                ratingImageStars.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBAction func photoClick(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "toPhotoViewController", sender: self)
        showAlert()
    }
    
    @IBAction func findBookClick(_ sender: UIButton) {
        performSegue(withIdentifier: "toPhotoViewController", sender: findBookButton )
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoViewController" {
            guard segue.destination is AttachPhotoViewController else {
                return
            }
        }
        //showAlert()
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "Attach a picture", message: "Choose a book cover", preferredStyle: .actionSheet)
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
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func image(forRating rating: Int) -> UIImage? {
        let imageName = "\(rating)Stars"
        return UIImage(named: imageName)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = chosenImage
        //self.performSegue(withIdentifier: "ShowEditView", sender: self)
        
        detailItem!.image = UIImagePNGRepresentation(chosenImage)! as NSData
        
        // Write detailItem to the database
        // Save the context.
        do {
            try managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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

extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: range)
        self.attributedText = attribute
    }
}
