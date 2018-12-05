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
    
    func configureView() {
        if let detail = detailItem {
            if let label = titleLabel {
                label.text = detail.title
            }
            if let label = authorLabel {
                label.text = detail.author
            }
            if let label = ratingLabel {
                label.text = detail.rating
            }
            if let label = releaseYearLabel {
                label.text = detail.releaseYear
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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
