import Foundation
import WebKit
import Alamofire


class TwitterViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    private let handler = "handler"
    @Published var data: [DetailModel] = []
    @Published var wkWebView: WKWebView?
    @Published var showWebView: Bool = false
    @Published var downloadResult: String?
    @Published var isLoading: Bool = false
    @Published var isShowingDownloadlView = false
    @Published var errorMsg: String?
    @Published var interstitialAd =  InterstitialAd()
    
    let defaultErrorMsg = "Please enter a valid twitter address. (x.com, twitter.com, t.co)"
    
    func isValidUrl(url: String) -> Bool {
        return url.lowercased().contains("https://x.com") ||
        url.lowercased().contains("https://video.twitter.com") ||
        url.lowercased().contains("https://twitter.com") ||
        url.lowercased().contains("https://t.co")
    }
    
    func getVideo(from url: String) {
        print("LOG: get viddeo" )
        guard
            isValidUrl(url: url)
        else { errorMsg = self.defaultErrorMsg ; return }
        
        guard let url = URL(string: url) else { return }
        
        self.clearGetVideo()
        self.setupWebView(with: url)
        
        //Hide Keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                                return
                            }
                        }
                    }
                } else if (medias == nil && responseText.contains("\"card\":{")) {
                    //FIXED: https://twitter.com/aykiricomtr/status/1741788570833109021
                    //Card şeklinde siteye yönlendirmeli olursa buraya geliyor.
                    let img = responseText.findBetween(start: #"\"media_url_https\":\""#, end: #"\""#) ?? ""
                    var video: [DetailVideoModel] = []
                        
                    let splits = responseText.components(separatedBy: #""content_type\":\"video/mp4\""#)
                    for split in splits {
                        let url = split.findBetween(start: #",\"url\":\""#, end: #"\""#)
                        if ( url?.contains(".mp4") == true) {
                            video.append(DetailVideoModel(url: url!, quality: getQuality(from: url!)))
                        }
                    }
                    
                    let data = DetailModel(id: 0, type: responseText.contains(".mp4")  ? .video : .photo, backgroundImageUrl: img, video: video)
                    self.data.append(data)
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
                        //print("LOG:", self.data)
                        i += 1
                    }
                }
                
                self.isShowingDownloadlView = true
                self.isLoading = false
                self.interstitialAd.showAd()
            } else {
                // Dizeyi veriye dönüştürme hatası
                self.errorMsg = "Data could not be processed"
            }
        } catch {
            // Çözümleme hatası
            self.errorMsg = "Data could not be analysed."
        }
        
    }
    
    ///İşlemi iptal et
    private func clearGetVideo() {
        self.isLoading = false
        self.errorMsg = nil
        self.data = []
        self.showWebView = false
        self.isShowingDownloadlView = false
    }
    
    private func setupWebView(with url: URL) {
        isLoading = true
        let config = WKWebViewConfiguration()
        let userScript = WKUserScript(source: getScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(userScript)
        config.userContentController.add(self, name: handler)
        
        wkWebView = WKWebView(frame: .zero, configuration: config)
        wkWebView?.navigationDelegate = self 
        wkWebView?.load(URLRequest(url: url))
    }
    
    private func getScript() -> String {
        if let filepath = Bundle.main.path(forResource: "script", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                print(error.localizedDescription)
            }
        } else {
//            print("script.js not found!")
        }
        return ""
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("LOG: YÜKLENME BİTTİ")
        //20 saniye içinde data parse edilmediyse yani download sayfasına geçilmediyse işlemi iptal et.
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // Anasayfada ve loading de ise.
            guard self.isShowingDownloadlView == false, self.isLoading else { return }
            self.clearGetVideo()
            self.errorMsg = "Cancelled due to timeout, please try again."
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
        self.isShowingDownloadlView = false
        errorMsg = error.localizedDescription
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
        self.isShowingDownloadlView = false
        errorMsg = error.localizedDescription
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
