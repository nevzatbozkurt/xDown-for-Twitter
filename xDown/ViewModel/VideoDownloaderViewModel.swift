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
    @Published var errorMsg: String?
    
    /// Download işlemi tamamlandı mı
    func isDownloadComplated() -> Bool {
        return self.progress == 1.00
    }
    
    /// İndirilmek istenen uzak sunucudaki fotoğraf veya videoyu telefonun fotoğraf galerisine kayıt eder.
    func downloadAndSaveMedia(fromURL url: URL, completionHandler: @escaping (_ success: Bool) -> Void) {
        errorMsg = nil
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(url.lastPathComponent)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let task = AF.download(url, to: destination)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Error saving video: unauthorized access")
                self.showNeedAuthView = true
                return
            }
            
            DispatchQueue.main.async {
                self.isDownloading = true
                //Download başladığını göstermek için indirme yüzdesini hemen arttırıyoruz
                self.progress = 0.00001
            }
            
            task.downloadProgress { progress in
                DispatchQueue.main.async {
                    self.progress = Float(progress.fractionCompleted)
                    print("LOG:", self.progress)
                }
            }
            .responseData { response in
                DispatchQueue.main.async {
                    if response.error == nil, let filePath = response.fileURL {
                        PHPhotoLibrary.shared().performChanges({
                            if response.response?.mimeType == "video/mp4" {
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
                            } else {
                                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filePath)
                            }
                        }) { success, error in
                            DispatchQueue.main.async {
                                self.isDownloading = false
                            }
                            
                            if success {
                                print("Video kayıt edildi.")
                            } else {
                                print("Error saving video: \(String(describing: error))")
                                self.errorMsg = error?.localizedDescription
                            }
                            
                            self.removeFileData(fileURL: filePath)
                        }
                    } else {
                        self.errorMsg = response.error?.localizedDescription
                        print("Error downloading video: \(String(describing: response.error?.localizedDescription))")
                    }
                }
            }
            

        }
    }
    
    
    /// Download edilmiş dosyayı siler.
    func removeFileData(fileURL: URL?) {
        guard let fileURL else { return }
        guard fileURL.isFileURL else { return }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to remove fileData: \(error)")
        }
    }
    
}
