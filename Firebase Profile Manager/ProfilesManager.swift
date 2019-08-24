//
//  ProfilesManager.swift
//  Firebase Profile Manager
//
//  Created by Su Yan on 8/20/18.
//  Copyright © 2018 Su Yan. All rights reserved.
//

import Foundation
import Firebase

class ProfilesManager {
    static let shared = ProfilesManager()
    static let baseRef = Database.database().reference(withPath: "profiles")

    enum Filters: Int {
        case none = 0
        case genderMale = 1
        case genderFemale = 2
        
        func filterImpl(_ profile: Profile) -> Bool {
            switch self {
            case .none:
                return true
            case .genderMale:
                return profile.gender == .male
            case .genderFemale:
                return profile.gender == .female
            }
        }
    }
    
    enum SortingCriteria: Int {
        case byId = 0
        case byAge = 1
        case byName = 2
        
        func query() -> DatabaseQuery {
            switch self {
            case .byId:
                return ProfilesManager.baseRef.queryOrderedByKey()
            case .byAge:
                return ProfilesManager.baseRef.queryOrdered(byChild: "age")
            case .byName:
                return ProfilesManager.baseRef.queryOrdered(byChild: "name")
            }
        }
    }
    
    var profiles: [Profile]
    var filter: Filters
    var sortingCriterion: SortingCriteria {
        willSet {
            currentQuery.removeAllObservers()
        }
    }
    var ascending: Bool
    var currentQuery: DatabaseQuery {
        return sortingCriterion.query()
    }
    
    private init() {
        profiles = []
        filter = .none
        sortingCriterion = .byId
        ascending = true
    }
    
    func signIn(completion: @escaping (Bool) -> ()) {
        Auth.auth().signInAnonymously { result, error in
            if error != nil {
                NSLog("Error: Failed to sign in anonymously")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func fetchProfiles(completion: @escaping () -> ()) {
        currentQuery.observe(.value) { [unowned self] snapshot in
            var newProfiles = [Profile]()
            for obj in snapshot.children {
                if let child = obj as? DataSnapshot {
                    newProfiles.append(Profile(from: child))
                }
            }
            if !self.ascending { newProfiles.reverse() }
            self.profiles = newProfiles.filter { self.filter.filterImpl($0) }
            completion()
        }
    }
    
    func updateProfile(_ profile: Profile) {
        ProfilesManager.baseRef.child(String(profile.id)).setValue(profile.jsonify())
    }
    
    func removeProfile(_ id: Int) {
        ProfilesManager.baseRef.child(String(id)).removeValue()
    }
    
    func nextAvailableProfileId() -> Int {
        return profiles.count
    }
}
