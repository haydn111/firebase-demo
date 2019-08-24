//
//  MainViewController.swift
//  Firebase Profile Manager
//
//  Created by Su Yan on 8/20/18.
//  Copyright © 2018 Su Yan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sortAndFilterButton: UIButton!
    @IBOutlet weak var profilesTableView: UITableView!
    
    var needsReloadProfiles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilesTableView.register(UITableViewCell.self, forCellReuseIdentifier: MainViewController.cellIdentifier)
        profilesTableView.tableFooterView = UIView(frame: .zero)
        addButton.isEnabled = false
        sortAndFilterButton.isEnabled = false
        ProfilesManager.shared.signIn { [unowned self] (success) in
            if success {
                self.reloadProfileData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReloadProfiles {
            needsReloadProfiles = false
            reloadProfileData()
        }
    }
    
    func reloadProfileData() {
        addButton.isEnabled = false
        sortAndFilterButton.isEnabled = false
        ProfilesManager.shared.fetchProfiles {
            DispatchQueue.main.async { [unowned self] in
                self.profilesTableView.reloadData()
                self.addButton.isEnabled = true
                self.sortAndFilterButton.isEnabled = true
            }
        }
    }
    
    @IBAction func addNewProfile(_ sender: UIButton) {
        let detailsVC = UIStoryboard.instantiateViewController("profileDetailsView") as! ProfileDetailViewController
        detailsVC.profile = Profile()
        present(detailsVC, animated: true, completion: nil)
    }
    
    @IBAction func showSortAndFilterOptions(_ sender: UIButton) {
        let sortAndFilterVC = UIStoryboard.instantiateViewController("sortFilterView") as! SortFilterViewController
        sortAndFilterVC.delegate = self
        present(sortAndFilterVC, animated: true, completion: nil)
    }
}

extension MainViewController: ProfilesSortAndFilterDelegate {
    func didFinishSortAndFilter() {
        reloadProfileData()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    static let cellIdentifier = "profileCell"
    static let backgroundColor = UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1)
    static let maleBackgroundColor = UIColor(red: 34.0/255.0, green: 126.0/255.0, blue: 252.0/255.0, alpha: 1)
    static let femaleBackgroundColor = UIColor(red: 208.0/255.0, green: 64.0/255.0, blue: 124.0/255.0, alpha: 1)
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfilesManager.shared.profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.cellIdentifier, for: indexPath)
        cell.styleForProfilesTable()

        let profile = ProfilesManager.shared.profiles[indexPath.row]
        cell.textLabel?.text = profile.name
        switch profile.gender {
        case .male:
            cell.contentView.backgroundColor = MainViewController.maleBackgroundColor
        case .female:
            cell.contentView.backgroundColor = MainViewController.femaleBackgroundColor
        case .unknown:
            cell.contentView.backgroundColor = MainViewController.backgroundColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = UIStoryboard.instantiateViewController("profileDetailsView") as! ProfileDetailViewController
        detailsVC.profile = Profile(from: ProfilesManager.shared.profiles[indexPath.row])
        present(detailsVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension UITableViewCell {
    func styleForProfilesTable() {
        textLabel?.textColor = .white
        textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        textLabel?.backgroundColor = .clear
        selectionStyle = .none
    }
}

extension UIStoryboard {
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    static func instantiateViewController(_ identifer: String) -> UIViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: identifer)
    }
}
