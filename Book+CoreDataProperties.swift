//
//  Book+CoreDataProperties.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 10/27/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var releaseYear: String?
    @NSManaged public var rating: String?
    @NSManaged public var image: NSObject?

}