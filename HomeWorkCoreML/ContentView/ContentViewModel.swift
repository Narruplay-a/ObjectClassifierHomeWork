//
//  ContentViewModel.swift
//  HomeWorkCoreML
//
//  Created by Adel Khaziakhmetov on 22.10.2021.
//

import SwiftUI
import CoreML
import Vision
import Combine
import UIKit

final class ContentViewModel: ObservableObject {
    @Published
    var resultString        : String
    private let emptyString : String                = "Проверка не проводилась"
    private var cancellables: Set<AnyCancellable>   = .init()
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: KeyboardImageClassifier_1().model)

            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    init() {
        resultString = emptyString
    }
    
    func checkPhoto(with image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func clearResult() {
        resultString = emptyString
    }
}

private extension ContentViewModel {
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.resultString = "Ошибка!"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.resultString = "Ошибка!"
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.resultString = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
