//
//  ViewController.swift
//  Project1
//
//  Created by Mikhail Strizhenov on 05.04.2020.
//  Copyright © 2020 Mikhail Strizhenov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                photos = try jsonDecoder.decode([Photo].self, from: savedPhotos)
            } catch {
                print("Failed to load photos.")
            }
        }
        
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(appRecommendation), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let photo = photos[indexPath.row]
        cell.textLabel?.text = photo.caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.imageNumber = indexPath.row + 1
            vc.numberOfImages = photos.count
            vc.selectedImage = photos[indexPath.row].image
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
//        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(jpegData, forKey: imageName)
        }
        
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Write caption to your photo", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let textFieldCaption = ac?.textFields?[0].text else { return }
            let imageData = UserDefaults.standard.object(forKey: imageName) as? Data ?? nil
            let photo = Photo(caption: textFieldCaption, image: imageData)
            self?.photos.append(photo)
            self?.save()
            self?.tableView.reloadData()
        })
        present(ac, animated: true)
        
        
    }
    @objc func appRecommendation() {
        let alert = UIAlertController(title: "Like our app?", message: "Please, recommend our app to other people!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Sure!", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @objc func addPhoto() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData  = try? jsonEncoder.encode(photos) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photos")
        } else {
            print("Failed to save photos.")
        }
    }
}

