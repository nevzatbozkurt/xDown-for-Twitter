import Foundation
import WebKit


class TwitterVideoDownloaderVM: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler {
    private let handler = "handler"
    @Published var wkWebView: WKWebView?
    @Published var showWebView: Bool = false
    @Published var downloadResult: String?
    @Published var twitterMedia: TwitterMediaModel?
    
    func getVideo(from url: String) {
        guard url != "" else { return }
        
        showWebView = false
        setupWebView(with: url)
    }
 
    private func setupWebView(with url: String) {
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
                            let twitterMedia = try JSONDecoder().decode(TwitterMediaModel.self, from: jsonData)
                            self.twitterMedia = twitterMedia
                            print(twitterMedia)
                            // Çözümleme başarılı oldu, twitterModel'i kullanabilirsiniz
                        } else {
                            // Dizeyi veriye dönüştürme hatası
                            print("hata")
                        }
                    } catch {
                        // Çözümleme hatası
                        print("Hata: \(error)")
                    }
                    
                }
            }
        }
    }
    
}
