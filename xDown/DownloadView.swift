//
//  DownloadView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 1.12.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import AVKit

struct DownloadView: View {
    var data: [DetailModel]?
    @State private var isPresented = false
    @State private var selectedTab: Int = 0
    
    func startDownload(downloadURL: String) {
        if let url = URL(string: downloadURL) {
            print("LOG: ", url)
        } else {
            //ERROR MESAJI VER
        }
    }
    
    var body: some View {
        VStack {
            if let data  {
                // Yukarıdaki yarıda fotoğraf ve oynatma butonu
                
                TabView(selection: $selectedTab) {
                    ForEach(data) { datum in
                        MediaItem(media: datum)
                            .tag(datum.id)
                    }
                }
                .tabViewStyle(.page)
                
                VStack {
                   
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                            .frame(width: 90, height: 90)
                            .padding(0)
                        
                        Button("Download to Gallery", action: {
                            let media = data[selectedTab]
                            
                            //Birden fazla kalite var ise önce kalite seçimini yapıp oradan download başlatıyoruz.
                            if (media.type == .video) {
                                self.isPresented = true
                                
                                //ViewModel Download func.
                                return
                            }
                            
                            
                            var downloadURL = ""
                            //GIF ise url buluyoruz.
                            if (media.type == .gif) {
                                if let video = media.video.first?.url {
                                    downloadURL = video
                                }
                            }
                            
                            //FOTO ise foto url seçiyoruz..
                            downloadURL = media.backgroundImageUrl
                            
                            
                            startDownload(downloadURL: downloadURL)
                            
                        })
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                            .actionSheet(isPresented: $isPresented) {
                            return {
                                ActionSheet(
                                    title: Text("Çözünürlük Seç"),
                                    buttons: data[selectedTab].video.compactMap { datum in
                                            .default(Text(datum.quality)
                                            ) {
                                                startDownload(downloadURL: datum.url)
                                            //ViewModel Download func.
                                        }
                                    } + [.cancel()]
                                )
                            }()
                        }
                            
                    }.padding(.horizontal)
                }
                .padding(.bottom)
                
                
                
            } else {
                Text("Video veya fotoğraf bulunamadı.")
            }
            
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onDisappear() {
            print("LOG: onDisappear 2")
        }
    }
}


struct MediaItem: View {
    var media: DetailModel
    @State private var isPlaying: Bool = false
    @State private var player: AVPlayer?
    //= AVPlayer(url: URL(string: "https://video.twimg.com/amplify_video/1730346441280016384/pl/RC5_ujzaEDw5zfJh.m3u8?tag=14&container=fmp4")!)
    
    var body: some View {
        ZStack(alignment: .center) {
            if (isPlaying && player != nil) {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                
                Button(action: {
                    // Videoyu oynatma işlemleri buraya eklenecek
                    player?.isMuted = true
                    player?.volume = 0
                    player?.pause()
                    self.isPlaying = false
                }) {
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .opacity(0.33)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                }
                .disabled(media.type == .photo)
                .opacity(media.type == .photo ? 0 : 1)
                
            } else {
                WebImage(url: URL(string: media.backgroundImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Button(action: {
                    if let url = media.video.first?.url, let videoUrl = URL(string: url) {
                        player = AVPlayer(url: videoUrl)
                        player?.seek(to: .zero)
                        player?.isMuted = false
                        player?.volume = 1
                        player?.play()
                        self.isPlaying = true
                    }
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height / 2)
                }
                .disabled(media.type == .photo)
                .opacity(media.type == .photo ? 0 : 1)
                
                
            }
                
        }
        .frame(maxWidth: .infinity)
    }
}

//struct DownloadView_Previews: PreviewProvider {
//    static var previews: some View {
//        let media = Media(displayURL: "http://display.url", expandedURL: "https://expanded.url", mediaURLHTTPS: "https://pbs.twimg.com/amplify_video_thumb/1730346441280016384/img/x62JpvlUS_3TC8fM.jpg", type: "video", url: "https://t.co/dP0xZwhCu3", videoInfo: VideoInfo(aspectRatio: [9,16], durationMillis: 21666, variants: [
//            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/720x1280/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 2176000),
//            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/320x568/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 632000),
//            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/480x852/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 950000)
//            ]))
//
//        let twitterMedia: TwitterMediaModel? = TwitterMediaModel(data: DataClass(tweetResult: TweetResult(result: Result(legacy: Legacy(entities: Entities(media: [media,media]), fullText: "Deneme")))))
//        DownloadView(twitterMedia: twitterMedia)
//    }
//}
