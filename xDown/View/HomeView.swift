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
    @State private var isPresentedHelpView = false
    
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
                    }.foregroundColor(.primary)

                            
                    Button {
                        self.isPresentedHelpView.toggle()
                    } label: {
                        LabeledIconButton(text: "How to make a download?", icon: "arrow.down.circle")
                    }.foregroundColor(.primary)
                    
//                    LabeledIconButton(text: "Remove ADS", icon: "star")
                }
                    
                Spacer()

                  
                
                if let err = twitterVM.errorMsg {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth:.infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                    
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
                
//                    Spacer()
                
                // MARK: ADMOB BANNER
                BannerAdView(adUnitID: adUnitIdBanner).frame(height: 320)

            }
            .padding()
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
        .keyboardType(.URL)
        .onOpenURL { incomingURL in
           handleIncomingURL(url: incomingURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            //Arka plandan ön plana geçince reklamı göster.
            pasteFromboard()
        }
        .sheet(isPresented: $isPresentedHelpView) {
            if #available(iOS 16.0, *) {
                HelpView()
                    .presentationDetents([.height(555)])
            } else {
                HelpView()
            }
        }
           

    }
    
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
    
    private func mailto(_ email: String) {
        let mailto = "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: mailto!) {
            openURL(url)
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
                .font(.headline)
                .bold()
                .offset(x: -15)
            
        } icon: {
            Image(systemName: icon)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
