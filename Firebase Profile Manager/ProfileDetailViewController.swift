//
//  ProfileDetailViewController.swift
//  Firebase Profile Manager
//
//  Created by Su Yan on 8/20/18.
//  Copyright © 2018 Su Yan. All rights reserved.
//

import UIKit
import Photos
import Firebase

class ProfileDetailViewController: UIViewController {
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var hobbiesTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var profile: Profile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.tag = TextFieldTags.nameField.rawValue
        ageTextField.tag = TextFieldTags.ageField.rawValue
        hobbiesTextField.tag = TextFieldTags.hobbiesField.rawValue
        updateSaveButtonEnabled()
        
        nameTextField.text = profile.name
        ageTextField.text = profile.age == 0 ? "": String(profile.age)
        hobbiesTextField.text = profile.hobbies
        switch profile.gender {
        case .male:
            genderSegmentedControl.selectedSegmentIndex = 0
        case .female:
            genderSegmentedControl.selectedSegmentIndex = 1
        case .unknown:
            genderSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        }
        
        ageTextField.attributedPlaceholder = NSMutableAttributedString(string:"0", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        photoButton.imageView?.contentMode = .scaleAspectFill
        
        if let imageUrl = profile.imageUrl {
            let ref = Storage.storage().reference(forURL: imageUrl)
            ref.getData(maxSize: 5 * 1024 * 1024) { [unowned self] (data, error) in
                if error != nil { NSLog(error!.localizedDescription) }
                if let data = data, let image = UIImage(data: data) {
                    self.photoButton.setImage(image, for: .normal)
                }
            }
        }
    }
    
    func updateSaveButtonEnabled() {
        let enabled = profile.name.count > 0 && profile.gender != .unknown
        saveButton.isEnabled = enabled
        let enabledColor = UIColor(red: 0, green: 184.0/255.0, blue: 0, alpha: 1)
        let disabledColor = UIColor.darkGray
        saveButton.backgroundColor = enabled ? enabledColor : disabledColor
    }
    
    @IBAction func genderSelected(_ sender: UISegmentedControl) {
        profile.gender = sender.selectedSegmentIndex == 0 ? . male : .female
        updateSaveButtonEnabled()
    }
    
    @IBAction func changePhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        uploadImage(photoButton.currentImage) { [unowned self] url in
            self.profile.imageUrl = url?.absoluteString
            ProfilesManager.shared.updateProfile(self.profile)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        if let url = profile.imageUrl {
            let ref = Storage.storage().reference(forURL: url)
            ref.delete(completion: nil)
        }
        ProfilesManager.shared.removeProfile(profile.id)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Photo utils
extension ProfileDetailViewController {
    func uploadImage(_ image: UIImage?, completion: @escaping (URL?) -> ()) {
        guard let image = image, let data = UIImageJPEGRepresentation(image, 0.05) else {
            completion(nil)
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970) + ".jpg"
        let imageRef = Storage.storage().reference(withPath: imageName)
        imageRef.putData(data, metadata: metadata) { metadata, error in
            if error != nil { NSLog(error!.localizedDescription) }
            imageRef.downloadURL { url, error in
                if error != nil { NSLog(error!.localizedDescription) }
                completion(url)
            }
        }
    }
}

extension ProfileDetailViewController: UITextFieldDelegate {
    private enum TextFieldTags: Int {
        case nameField = 0
        case ageField = 1
        case hobbiesField = 2
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        var shouldChange = true
        switch TextFieldTags(rawValue: textField.tag)! {
        case .nameField:
            profile.name = resultString
        case .ageField:
            if resultString.count > 3 {
                shouldChange = false
            } else if let age = UInt(resultString) {
                profile.age = age
            } else {
                profile.age = 0
            }
        case .hobbiesField:
            profile.hobbies = resultString
        }
        updateSaveButtonEnabled()
        return shouldChange
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
            let size = CGSize(width: 400, height: 240)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { [unowned self] result, info in
                guard let image = result else {
                    return
                }
                self.photoButton.setImage(image, for: .normal)
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoButton.setImage(image, for: .normal)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
