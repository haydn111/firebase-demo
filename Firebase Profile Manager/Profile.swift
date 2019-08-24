//
//  Profile.swift
//  Firebase Profile Manager
//
//  Created by Su Yan on 8/20/18.
//  Copyright © 2018 Su Yan. All rights reserved.
//

import Foundation
import Firebase

class Profile {
    enum Gender: String {
        case unknown = "unknown"
        case male = "male"
        case female = "female"
    }
    
    var id: Int
    var gender: Gender
    var name: String
    var age: UInt
    var imageUrl: String?
    var hobbies: String
    var databaseRef: DatabaseReference?
    
    init() {
        id = ProfilesManager.shared.nextAvailableProfileId()
        gender = .unknown
        name = ""
        age = 0
        hobbies = ""
    }
    
    init(from profile: Profile) {
        id = profile.id
        gender = profile.gender
        name = profile.name
        age = profile.age
        imageUrl = profile.imageUrl
        hobbies = profile.hobbies
    }
    
    convenience init(from snapshot: DataSnapshot) {
        self.init()
        databaseRef = snapshot.ref
        if let value = snapshot.value as? [String: Any] {
            id = value["id"] as! Int
            gender = Gender(rawValue: value["gender"] as! String) ?? .unknown
            name = value["name"] as! String
            age = value["age"] as! UInt
            hobbies = value["hobbies"] as! String
            imageUrl = value["imageUrl"] as? String
        }
    }
    
    func jsonify() -> [String: Any] {
        var json: [String: Any] = [
            "id": id,
            "gender": gender.rawValue,
            "name": name,
            "age": age,
            "hobbies": hobbies
        ]
        if let urlString = imageUrl {
            json["imageUrl"] = urlString
        }
        return json
    }
}
