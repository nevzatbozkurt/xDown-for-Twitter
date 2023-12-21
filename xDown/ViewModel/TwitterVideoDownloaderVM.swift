import Foundation
import WebKit
import Alamofire


class TwitterVideoDownloaderVM: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    private let handler = "handler"
    @Published var data: [DetailModel] = []
    @Published var wkWebView: WKWebView?
    @Published var showWebView: Bool = false
    @Published var downloadResult: String?
    @Published var isLoading: Bool = false
    @Published var isShowingDownloadlView = false
    
    func getVideo(from url: String) {
        guard url != "" else { return }
    
        showWebView = false
        setupWebView(with: url)
    }
    
    /// Gönderilien urlden video kalitesini döner.
    private func getQuality(from url: String) -> String {
        let splited = url.components(separatedBy: "/")
        if splited.count < 2 { return "Download" }
        let q = String(splited[splited.count - 2])
        return q
    }
    
    private func prepareDetailModel(_ responseText: String) {
        do {
            if let jsonData = responseText.data(using: .utf8) {
                // Çözümleme başarılı oldu, twitterModel'i kullanabilirsiniz
                let twitterMedia = try JSONDecoder().decode(TwitterMediaModel.self, from: jsonData)
                let medias = twitterMedia.data?.tweetResult?.result?.legacy?.entities?.media
                
                if medias == nil && //Eğer bu twitte hiç medya yoksa
                   responseText.contains("quoted_status_result") //Alıntı yapılan bir twit var mı ona bakıp onun verisini çekiyoruz.
                {
                    let split = responseText.components(separatedBy: "quoted_status_result")
                    if split.count > 1 {
                        let split2 = split[1].components(separatedBy: "\"extended_entities\":{")
                        if split2.count > 1 {
                            if let url =  split2[1].findBetween(start: "\"expanded_url\":\"", end: "\"") {
                                
                                self.getVideo(from: url)
                                self.isShowingDownloadlView = false
                                
                                return
                            }
                        }
                    }
                }
                
                var i = 0
                //Detail Modeli doldur.
                if let medias {
                    for media in medias {
                        let mediaType: DetailMediaType = {
                            switch media.type {
                            case "video":
                                return .video
                            case "animated_gif":
                                return .gif
                            case "photo":
                                return .photo
                            default:
                                return .none
                            }
                        }()
                        
                        
                        let img = media.mediaURLHTTPS ?? ""
                        
                        let video: [DetailVideoModel] = {
                            let videoURLs = media.videoInfo?.variants?.compactMap { variant in
                                if let url = variant.url, !url.contains("m3u8") {
                                    return DetailVideoModel(url: url, quality: getQuality(from: url))
                                }
                                return nil
                            }
                            return videoURLs ?? []
                        }()
                        
                        let detailModel = DetailModel(id: i, type: mediaType, backgroundImageUrl: img, video: video)
                        self.data.append(detailModel)
                        print("LOG:", self.data)
                        i += 1
                    }
                }
                
                self.isShowingDownloadlView = true
                self.isLoading = false
                
            } else {
                // Dizeyi veriye dönüştürme hatası
                showError()
            }
        } catch {
            // Çözümleme hatası
            showError()
        }
        
    }
    
    private func setupWebView(with url: String) {
        isLoading = true
        let config = WKWebViewConfiguration()
        let userScript = WKUserScript(source: getScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(userScript)
        config.userContentController.add(self, name: handler)
        
        wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView?.navigationDelegate = self 
        wkWebView?.load(URLRequest(url: URL(string: url)!))
    }
    
    private func getScript() -> String {
        if let filepath = Bundle.main.path(forResource: "script", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                print(error)
            }
        } else {
            print("script.js not found!")
        }
        return ""
    }
    
    func showError() {
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dict = message.body as? Dictionary<String, AnyObject>,
            let status = dict["status"] as? Int,
            let responseUrl = dict["responseURL"] as? String,
            let responseText = dict["responseText"] as? String
        {
            if (responseUrl.contains("TweetResultByRestId")) { //URL içinde
                if (status == 200) {
                    prepareDetailModel(responseText)
                }
            }
        }
    }
}
