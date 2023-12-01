//
//  ContentView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 16.11.2023.
//

import SwiftUI

struct HomeView: View {
    @StateObject var twitterDownloader = TwitterVideoDownloaderVM()
    @State var urlText = "https://twitter.com/_KomutanLogar/status/1730346492697948575"
    
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                NavigationLink(destination: DownloadView(), isActive: $twitterDownloader.isShowingDownloadlView) {  }
                
                
                //MARK: TOP BUTTONS
                VStack(alignment: .leading) {
                    LabeledIconButton(text: "Help", icon: "envelope")
                    LabeledIconButton(text: "Remove ADS", icon: "star")
                    LabeledIconButton(text: "How to make a use", icon: "arrow.down.circle")
                }
                
                Spacer()
                
                //MARK: ADMOB BANNER
                
                
                Spacer()
                
                //MARK: URL INPUT
                TextField("Twitter Video URL & Photo or GIF URL", text: $urlText)
                    .keyboardType(.URL)
                    .roundedStyle(backgroundColor: .black.opacity(0.1))
                    .padding(.top, 20)
                
                
                //MARK: FIND BUTTON
                Button {
                    twitterDownloader.getVideo(from: urlText)
                } label: {
                    if (twitterDownloader.isLoading) {
                        ProgressView()
                                   .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                   .roundedStyle(backgroundColor: Color.black.opacity(0.88))
                    } else {
                        Text("Find")
                            .roundedStyle(backgroundColor: Color.black.opacity(0.88))
                    }
                }
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
                //.background(.secondary.opacity(0.2))
                .clipShape(Circle())
                .padding([.horizontal])
                .foregroundColor(.black)
        }.font(.title2)
    }
}