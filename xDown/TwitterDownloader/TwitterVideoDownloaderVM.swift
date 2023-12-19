import Foundation
import WebKit
import Alamofire


class TwitterVideoDownloaderVM: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    private let handler = "handler"
    @Published var wkWebView: WKWebView?
    @Published var showWebView: Bool = false
    @Published var downloadResult: String?
    @Published var twitterMedia: TwitterMediaModel?
    @Published var isLoading: Bool = false
    @Published var isShowingDownloadlView = false
    @Published var quotedTwitUrl: String?
    
    func getVideo(from url: String) {
        guard url != "" else { return }
    
        showWebView = false
        setupWebView(with: url)
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
                    do {
                        if let jsonData = responseText.data(using: .utf8) {
                            // Çözümleme başarılı oldu, twitterModel'i kullanabilirsiniz
                            let twitterMedia = try JSONDecoder().decode(TwitterMediaModel.self, from: jsonData)
                            self.twitterMedia = twitterMedia
                            
                            if responseText.contains("quoted_status_result")  {
                                let split = responseText.components(separatedBy: "quoted_status_result")
                                if split.count > 1 {
                                    let split2 = split[1].components(separatedBy: "\"extended_entities\":{")
                                    if split2.count > 1 {
                                        if let url =  split2[1].findBetween(start: "\"expanded_url\":\"", end: "\"") {
                                            //Alıntı yapılan bir twit ise ve media olarak herhangi bir şey yok ise altıntı içindeki twittin urlni bulup ona gidiyoruz.
                                            if self.twitterMedia?.data?.tweetResult?.result?.legacy?.entities?.media == nil {
                                                self.getVideo(from: url)
                                                self.isShowingDownloadlView = false
                                                
                                                return
                                            }
                                        }
                                    }
                                }
                            }
                            
                            print("LOG asdasd")
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
            }
        }
    }
}
