//
//  SortFilterViewController.swift
//  Firebase Profile Manager
//
//  Created by Su Yan on 8/21/18.
//  Copyright © 2018 Su Yan. All rights reserved.
//

import UIKit

class SortFilterViewController: UIViewController {

    @IBOutlet weak var sortedBy: UISegmentedControl!
    @IBOutlet weak var ascedingDescending: UISegmentedControl!
    @IBOutlet weak var filter: UISegmentedControl!
    
    var delegate: ProfilesSortAndFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sortedBy.selectedSegmentIndex = ProfilesManager.shared.sortingCriterion.rawValue
        ascedingDescending.selectedSegmentIndex = ProfilesManager.shared.ascending ? 0 : 1
        filter.selectedSegmentIndex = ProfilesManager.shared.filter.rawValue
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func apply(_ sender: UIButton) {
        ProfilesManager.shared.sortingCriterion = ProfilesManager.SortingCriteria(rawValue: sortedBy.selectedSegmentIndex)!
        ProfilesManager.shared.ascending = ascedingDescending.selectedSegmentIndex == 0
        ProfilesManager.shared.filter = ProfilesManager.Filters(rawValue: filter.selectedSegmentIndex)!
        delegate?.didFinishSortAndFilter()
        dismiss(animated: true, completion: nil)
    }
}

protocol ProfilesSortAndFilterDelegate {
    func didFinishSortAndFilter()
}
