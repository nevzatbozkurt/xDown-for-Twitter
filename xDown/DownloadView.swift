//
//  DownloadView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 1.12.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct DownloadView: View {
    @State private var selectedQuality: String = "720p"
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            // Yukarıdaki yarıda fotoğraf ve oynatma butonu
            ZStack {
                WebImage(url: URL(string: "https://pbs.twimg.com/amplify_video_thumb/1730346441280016384/img/x62JpvlUS_3TC8fM.jpg"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
 

                Button(action: {
                    // Videoyu oynatma işlemleri buraya eklenecek
                    self.isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding()
                }
            }

            // Aşağıdaki yarıda video kalite butonları
            HStack {
                Button(action: {
                    // 360p seçildiğinde yapılacak işlemler
                    self.selectedQuality = "360p"
                }) {
                    Text("360p")
                        .padding()
                        .background(selectedQuality == "360p" ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    // 720p seçildiğinde yapılacak işlemler
                    self.selectedQuality = "720p"
                }) {
                    Text("720p")
                        .padding()
                        .background(selectedQuality == "720p" ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    // 1080p seçildiğinde yapılacak işlemler
                    self.selectedQuality = "1080p"
                }) {
                    Text("1080p")
                        .padding()
                        .background(selectedQuality == "1080p" ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView()
    }
}
