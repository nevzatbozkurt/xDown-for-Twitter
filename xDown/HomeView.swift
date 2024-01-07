//
//  ContentView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 16.11.2023.
//

import SwiftUI
import WebKit

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @StateObject var twitterVM = TwitterViewModel()
    @State var urlText = ""   
    
    func pasteFromboard(showErrorMessage : Bool = false) {
        guard let clipboardText = UIPasteboard.general.string else  { return }
        guard let _ = URL(string: clipboardText)  else { return }
        guard clipboardText != urlText else { return }
        guard twitterVM.isValidUrl(url: clipboardText) else {
            if showErrorMessage {
                twitterVM.errorMsg = twitterVM.defaultErrorMsg;
            }
            return
        }
        
        self.urlText = clipboardText
        findButtonActions()
        
        
    }
    
    func mailto(_ email: String) {
        let mailto = "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: mailto!) {
            openURL(url)
        }
    }
    
    var body: some View {
        NavigationView {
                        
            VStack(alignment: .leading) {
                
                NavigationLink(destination: DownloadView(data: twitterVM.data), isActive: $twitterVM.isShowingDownloadlView) {  }
                
                if twitterVM.showWebView, let wv = twitterVM.wkWebView {
                    WebView2(wkWebView: wv)
                }
                
                //MARK: TOP BUTTONS
                VStack(alignment: .leading) {
                    Button {
                        mailto("nevzatbozkurtapp@gmail.com")
                    } label: {
                        LabeledIconButton(text: "Help", icon: "envelope")
                    }.foregroundColor(.white)

                            
                    
//                    LabeledIconButton(text: "Remove ADS", icon: "star")
                    LabeledIconButton(text: "How to make a use", icon: "arrow.down.circle")
                }
                
                Spacer()
                
                //MARK: ADMOB BANNER
                BannerAdView(adUnitID: adUnitIdBanner)
                        //.frame(height: screen.height / 2)
                    .frame(height: 320)
                             

                Spacer()
                
                if let err = twitterVM.errorMsg {
                    Text(err)
                        .font(.headline)
                        .roundedStyle(backgroundColor: .red.opacity(0.5), cornerRadius: 8)
                    
                }
                
                //MARK: URL INPUT
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    TextField("Twitter Video URL & Photo or GIF URL", text: $urlText, onCommit: findButtonActions)
                        .keyboardType(.URL)
                        .roundedStyle(backgroundColor: .secondary.opacity(0.3))
                        .onChange(of: urlText) { _ in
                            twitterVM.errorMsg = nil
                        }
                    
                    
                    Button {
                        pasteFromboard(showErrorMessage: true)
                    } label: {
                        Image(systemName: "doc.on.clipboard.fill")
                            .padding(6)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.primary.opacity(0.3))
                            .background(Color.secondary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .font(.title2)
                    }

                   
                }
                    
                
                //MARK: FIND BUTTON
                Button {
                    findButtonActions()
                } label: {
                    if (twitterVM.isLoading) {
                        ProgressView()
                                   .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                   .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                    } else {
                        Text("Find")
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                    }
                }.disabled(twitterVM.isLoading)
            }
            .padding()
        }
        .onOpenURL { incomingURL in
           handleIncomingURL(url: incomingURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            //Arka plandan ön plana geçince reklamı göster.
            pasteFromboard()
        }
    }
    
    private func findButtonActions() {
        twitterVM.getVideo(from: urlText)
    }
    
    private func handleIncomingURL(url: URL) {
        guard url.scheme == "nevzatbozkurtxdown" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("LOG: Invalid URL")
            return
        }

        guard let urlQuery = components.queryItems?.first(where: { $0.name == "url" })?.value else {
            print("LOG: url name not found")
            return
        }
        
        self.urlText = urlQuery
        findButtonActions()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct LabeledIconButton: View {
    var text: String
    var icon: String
    
    var body: some View {
        Label {
            Text(text)
                .bold()
                .offset(x: -15)
            
        } icon: {
            Image(systemName: icon)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .clipShape(Circle())
                .padding([.horizontal])
                .foregroundColor(.white)
        }.font(.title2)
    }
}

struct WebView2: UIViewRepresentable {
    let wkWebView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return wkWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Gerekirse güncelleme yapılabilir
    }
}
