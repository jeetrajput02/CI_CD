//
//  CustomAudioPickerView.swift
//  WhosNext
//
//  Created by differenz240 on 15/11/22.
//

import Foundation
import SwiftUI
import UIKit

struct CustomAudioPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var audioURL: URL?
    
    func makeCoordinator() -> AudioCoordinator {
        return AudioCoordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomAudioPickerView>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator

        return picker
    }
    
    func updateUIViewController(_ uiViewController: CustomAudioPickerView.UIViewControllerType, context: UIViewControllerRepresentableContext<CustomAudioPickerView>) {}
}

// MARK: - AudioCoordinator
class AudioCoordinator: NSObject, UIDocumentPickerDelegate {
    var parent: CustomAudioPickerView
    
    init(parent: CustomAudioPickerView) {
        self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let audioUrl = urls.first else { return }
        print("picked audio url: \(audioUrl.absoluteString)")
        
        self.parent.audioURL = audioUrl
        self.parent.isPresented = false
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.parent.isPresented = false
    }
}
