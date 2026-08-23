/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2026 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  FlightDeckScan.swift
//  MFBSample
//
//  Created by Eric Berman on 8/23/26.
//

// FlightDeckCapture.swift

import UIKit

/// Owns the "pick a source, capture/select an image, upload, get opaque JSON back"
/// flow for the Flight Deck scan feature. Fully self-contained so it doesn't
/// collide with any UIImagePickerControllerDelegate conformance the presenting
/// view controller already has for other flows.
final class FlightDeckCapture: NSObject {

    typealias Completion = (Result<String, FlightDeckCaptureError>) -> Void

    enum FlightDeckCaptureError: LocalizedError {
        case cancelled
        case network(Error)
        case serverError(String)
        case malformedResponse

        var errorDescription: String? {
            switch self {
            case .cancelled: return nil // no need to surface cancellation as an error
            case .network(let e): return e.localizedDescription
            case .serverError(let msg): return msg
            case .malformedResponse: return String(localized: "Error")
            }
        }
    }

    private weak var presenter: UIViewController?
    private var completion: Completion?

    /// Keep a strong reference to self alive for the duration of the flow,
    /// since the presenting VC only needs to hold a var to kick this off,
    /// not retain it across the whole async round trip.
    private static var activeCapture: FlightDeckCapture?
    
    private var progressAlert: UIAlertController?
    
    static func present(from viewController: UIViewController, completion: @escaping Completion) {
        let capture = FlightDeckCapture()
        capture.presenter = viewController
        capture.completion = completion
        activeCapture = capture
        capture.presentSourceChoice()
    }

    private func presentSourceChoice() {
        guard let presenter else { return }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: String(localized: "flightDeckTakePhoto", comment: "Take Photo"), style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }

        sheet.addAction(UIAlertAction(title: String(localized: "flightDeckChoosePhoto", comment: "Choose photo"), style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })

        sheet.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel"), style: .cancel) { [weak self] _ in
            self?.finish(.failure(.cancelled))
        })

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        presenter.present(sheet, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard let presenter else { return }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = sourceType

        if let popover = picker.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        presenter.present(picker, animated: true)
    }

    private func finish(_ result: Result<String, FlightDeckCaptureError>) {
        guard let alert = progressAlert else {
            completion?(result)
            completion = nil
            FlightDeckCapture.activeCapture = nil
            return
        }

        alert.dismiss(animated: true) { [weak self] in
            self?.completion?(result)
            self?.completion = nil
            FlightDeckCapture.activeCapture = nil
        }
        progressAlert = nil
    }

    private func uploadFlightDeckImage(_ image: UIImage) {
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            finish(.failure(.malformedResponse))
            return
        }
        guard let url = URL(string: "https://\(MFBHOSTNAME)\(MFBConstants.MFBAIRCRAFTIMAGEFLIGHTDECK)") else {
            finish(.failure(.malformedResponse))
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        appendFormField(name: "txtAuthToken", value: MFBProfile.sharedProfile.AuthToken)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"deck.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(jpegData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let error {
                    self.finish(.failure(.network(error)))
                    return
                }
                guard let data else {
                    self.finish(.failure(.malformedResponse))
                    return
                }

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200

                // Non-2xx: server is signaling an error out-of-band from your JSON contract.
                // Treat the body as a plain-text message rather than trying to parse it as JSON.
                guard (200...299).contains(statusCode) else {
                    let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.finish(.failure(.serverError(message?.isEmpty == false ? message! : String(localized: "genericUploadError"))))
                    return
                }

                do {
                    guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        self.finish(.failure(.malformedResponse))
                        return
                    }
                    let success = obj["success"] as? Bool ?? false
                    if !success {
                        let msg = obj["error"] as? String ?? String(localized: "genericUploadError")
                        self.finish(.failure(.serverError(msg)))
                        return
                    }
                    guard let parsedResults = obj["parsedResults"] else {
                        self.finish(.failure(.malformedResponse))
                        return
                    }
                    let parsedData = try JSONSerialization.data(withJSONObject: parsedResults, options: [])
                    guard let parsedJSON = String(data: parsedData, encoding: .utf8) else {
                        self.finish(.failure(.malformedResponse))
                        return
                    }
                    self.finish(.success(parsedJSON))
                } catch {
                    self.finish(.failure(.malformedResponse))
                }
            }
        }.resume()
    }
}

extension FlightDeckCapture: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let presenter = self.presenter else { return }
            guard let image = info[.originalImage] as? UIImage else {
                self.finish(.failure(.malformedResponse))
                return
            }
            self.progressAlert = presenter.presentProgressAlert(message: String(localized: "flightDeckScanPhoto",  comment: "Scanning in progress")) {
                self.uploadFlightDeckImage(image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.finish(.failure(.cancelled))
        }
    }
}
