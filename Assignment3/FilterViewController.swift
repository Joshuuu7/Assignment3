//
//  FilterViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 10/17/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?,sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
    
    // Sort By Section
    @IBOutlet weak var titleAZSortCell: UITableViewCell!
    
    var coreDataStack: CoreDataStack!
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    var lastSelection: IndexPath? = nil
    
    lazy var titleSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Book.title), ascending: true, selector: compareSelector)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        if lastSelection != nil && lastSelection?.section == indexPath.section {
            tableView.cellForRow(at: lastSelection!)?.accessoryType = .none
        }
        
        
        switch cell {
            
            
        //Sort By section
        case titleAZSortCell:
            selectedSortDescriptor = titleSortDescriptor

        default: break
        }
        
        cell.accessoryType = .checkmark
        lastSelection = indexPath
    }
    
}
