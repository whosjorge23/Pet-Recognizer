//
//  ViewController.swift
//  Pet Recognizer
//
//  Created by Jorge Giannotta on 01/04/2019.
//  Copyright © 2019 Jorge Giannotta. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePickerPhoto = UIImagePickerController()
    let imagePickerAlbum = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePickerPhoto.delegate = self
        imagePickerAlbum.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {fatalError("couldn't convert uiimage to CIImage")}
            
            detect(image: ciimage)
        }
        
        imagePickerPhoto.dismiss(animated: true, completion: nil)
        
        imagePickerAlbum.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {fatalError("can't load ML model")}
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("unexpected result type from VNCoreMLRequest")}
            
            let topResult = results.first?.identifier
            
            self.navigationItem.title = topResult
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePickerPhoto.sourceType = .camera
        imagePickerPhoto.allowsEditing = false
        present(imagePickerPhoto, animated: true, completion: nil)
    }
    
    @IBAction func albumTapped(_ sender: UIBarButtonItem) {
        
        imagePickerAlbum.sourceType = .photoLibrary
        imagePickerAlbum.allowsEditing = false
        present(imagePickerAlbum, animated: true, completion: nil)
    }
}

