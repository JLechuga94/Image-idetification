//
//  ViewController.swift
//  AR_AI
//
//  Created by Julian Lechuga Lopez on 5/7/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imagePicker = UIImagePickerController()
    var model = GoogLeNetPlaces()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        self.photoImageView.image = pickedImage
        
        processImage(image: pickedImage)
    }
    
    func processImage(image: UIImage)  {
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create the ciImage object")
        }
        guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
            fatalError("Unable to create vision model")
        }
        
        let visionRequest = VNCoreMLRequest(model: visionModel){ request, error in
            if error != nil {
                return
            }
            guard let results = request.results as? [VNClassificationObservation] else {return}
            
            let classifications = results.map {observation in
                "\(observation.identifier)  Confidence: \(observation.confidence*100)%"
            }
            
            
            DispatchQueue.main.async{
                print(classifications.count)
                self.descriptionTextView.text = classifications[0..<3].joined(separator: "\n")
            }
        }
        
        let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
    }
    
    
    
    @IBAction func loadImage(_ sender: Any) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
}

