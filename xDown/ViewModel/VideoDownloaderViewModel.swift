//
//  VideoDownloaderViewModel.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 30.12.2023.
//

import Foundation
import Alamofire
import Photos
import UIKit

class VideoDownloaderViewModel: ObservableObject {
    @Published var isDownloading: Bool = false
    @Published var progress: Float = 0
    /// Fotoğraf galerisi izni vermesi için yönlendiren viewi göster
    @Published var showNeedAuthView = false
    
    func photoAuth() -> Bool {
        var r = false
        PHPhotoLibrary.requestAuthorization { status in
            r = status == .authorized
        }
        print("auth:", r)
        return r
    }
    
    func downloadAndSaveMedia(fromURL url: URL, completionHandler: @escaping (_ success: Bool) -> Void) {
        guard photoAuth() else {
            showNeedAuthView = true
            return completionHandler(false)
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(url.lastPathComponent)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        let task = AF.download(url, to: destination)
        task.downloadProgress { progress in
            DispatchQueue.main.async {
                self.progress = Float(progress.fractionCompleted)
                print("LOG:", self.progress)
            }
        }
        .responseData { response in
            DispatchQueue.main.async {
                self.isDownloading = false
                if response.error == nil, let filePath = response.fileURL {
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized else {
                            print("Error saving video: unauthorized access")
                            return
                        }
                        
                        PHPhotoLibrary.shared().performChanges({
                            if response.response?.mimeType == "video/mp4" {
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
                            } else {
                                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filePath)
                            }
                        }) { success, error in
                            self.isDownloading = false
                            if success {
                                print("Video kayıt edildi.")
                            } else {
                                print("Error saving video: \(String(describing: error))")
                            }
                        }
                    }
                } else {
                    
                }
            }
        }
        
        self.isDownloading = true
        //Download başladığını göstermek için indirme yüzdesini hemen arttırıyoruz
        self.progress = 0.00001
    }
    
   
    
}
