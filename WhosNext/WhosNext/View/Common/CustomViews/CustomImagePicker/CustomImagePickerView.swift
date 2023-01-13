//
//  CustomImagePickerView.swift
//  WhosNext
//
//  Created by differenz195 on 17/10/22.
//

import Foundation
import UIKit
import MobileCoreServices
import SwiftUI

struct CustomImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .camera
    var isVideoAllow: Bool = false
    
    @Binding var arrImage: [UIImage]
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(image: self.$image, isPresented: self.$isPresented, videoURL: self.$videoURL, arrImage: self.$arrImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = self.sourceType
        
        if self.isVideoAllow == true {
            pickerController.mediaTypes = ["public.movie"]
            pickerController.videoQuality = .typeIFrame1280x720
            pickerController.videoMaximumDuration = TimeInterval(30.0)
        } else {
            pickerController.mediaTypes = ["public.image"]
        }
        // pickerController.mediaTypes = [kUTTypeMovie as String]
        pickerController.delegate = context.coordinator
        pickerController.allowsEditing = true

        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }
}

// MARK: - Image Picker View Coordinator
class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var arrImage: [UIImage]
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?
    
    init(image: Binding<UIImage?>, isPresented: Binding<Bool>, videoURL: Binding<URL?>, arrImage: Binding<[UIImage]>) {
        self._image = image
        self._isPresented = isPresented
        self._videoURL = videoURL
        self._arrImage = arrImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.image = image
            self.arrImage.append(image)
        } else if let videourl = info[.mediaURL] as? URL {
            self.videoURL = videourl
        }

        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
        self.videoURL = nil
    }
}
