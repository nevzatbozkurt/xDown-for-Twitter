//
//  ContentView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 16.11.2023.
//

import SwiftUI
import WebKit

struct WebView2: UIViewRepresentable {
    let wkWebView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return wkWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Gerekirse güncelleme yapılabilir
    }
}

struct HomeView: View {
    @StateObject var twitterVM = TwitterViewModel()
    @State var urlText = "https://twitter.com/FOXhaber/status/1740640127700099084"
    
    
    var body: some View {
        
        NavigationView {
                        
            VStack(alignment: .leading) {
                
                NavigationLink(destination: DownloadView(data: twitterVM.data), isActive: $twitterVM.isShowingDownloadlView) {  }
                
                if twitterVM.showWebView, let wv = twitterVM.wkWebView {
                    WebView2(wkWebView: wv)
                }
                
                //MARK: TOP BUTTONS
                VStack(alignment: .leading) {
                    LabeledIconButton(text: "Help", icon: "envelope")
                    LabeledIconButton(text: "Remove ADS", icon: "star")
                    LabeledIconButton(text: "How to make a use", icon: "arrow.down.circle")
                }
                
                Spacer()
                
                //MARK: ADMOB BANNER
                
                
                Spacer()
                
                
                
                if let err = twitterVM.errorMsg {
                    Text(err)
                        .font(.headline)
                        .roundedStyle(backgroundColor: .red.opacity(0.5), cornerRadius: 8)
                    
                }
                
                //MARK: URL INPUT
                TextField("Twitter Video URL & Photo or GIF URL", text: $urlText)
                    .keyboardType(.URL)
                    .roundedStyle(backgroundColor: .secondary.opacity(0.3))
                    
                
                //MARK: FIND BUTTON
                Button {
                    twitterVM.getVideo(from: urlText)
                } label: {
                    if (twitterVM.isLoading) {
                        ProgressView()
                                   .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                   .roundedStyle(backgroundColor: Color.secondary.opacity(0.88))
                    } else {
                        Text("Find")
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.88))
                    }
                }.disabled(twitterVM.isLoading)
            }
            .padding()
        }
        
        
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
