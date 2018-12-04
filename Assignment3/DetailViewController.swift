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
    
}
