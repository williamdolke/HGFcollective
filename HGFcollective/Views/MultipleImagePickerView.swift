//
//  MultipleImagePickerView.swift
//  HGFcollective
//
//  Created by William Dolke on 03/06/2023.
//

import SwiftUI
import PhotosUI

struct MultipleImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    @Binding var images: [UIImage]

    let limit: Int

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Only show photos
        configuration.selectionLimit = limit // 0 means no limit
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        let parent: MultipleImagePickerView

        init(parent: MultipleImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let error = error {
                        logger.error("Error loading image: \(error)")
                    } else if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}
