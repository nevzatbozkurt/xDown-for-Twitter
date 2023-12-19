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
    var twitterMedia: TwitterMediaModel?
    @State private var isPresented = false
    @State private var selectedTab: Int = 0
    
    
    func startDownload(downloadURL: String) {
        if let url = URL(string: downloadURL) {
            print("LOG: ", url)
        } else {
            //ERROR MESAJI VER
        }
    }
    
    func getQuality(url: String) -> String {
        let splited = url.components(separatedBy: "/")
        if splited.count < 2 { return "Download" }
        let q = String(splited[splited.count - 2])
        return q
    }
    
    var body: some View {
        VStack {
            if let medias = twitterMedia?.data?.tweetResult?.result?.legacy?.entities?.media {
                // Yukarıdaki yarıda fotoğraf ve oynatma butonu
                
                TabView(selection: $selectedTab) {
                        ForEach(Array(medias.enumerated()), id: \.1.id) { (index, media) in
                        MediaItem(media: media)
                            .tag(index)
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
                            let media = medias[selectedTab]
                            
                            //Birden fazla kalite var ise önce kalite seçimini yapıp oradan download başlatıyoruz.
                            if (media.type == "video") {
                                self.isPresented = true
                                
                                //ViewModel Download func.
                                return
                            }
                            
                            
                            var downloadURL = ""
                            //GIF ise url buluyoruz.
                            if (media.type == "animated_gif") {
                                if let video = media.videoInfo?.variants?.first?.url {
                                    downloadURL = video
                                }
                            }
                            
                            //FOTO ise url buluyoruz.
                            if let url = media.mediaURLHTTPS {
                                downloadURL = url
                            }
                            
                            startDownload(downloadURL: downloadURL)
                            
                        })
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                            .actionSheet(isPresented: $isPresented) {
                                let media = medias[selectedTab].videoInfo?.variants
                                let videoURLs = media?.compactMap { variant in
                                    if let url = variant.url, !url.contains("m3u8") {
                                        return url
                                    }
                                    return nil
                                } ?? [""]
                              
                              
                                return {
                                    ActionSheet(
                                        title: Text("Çözünürlük Seç"),
                                        buttons: videoURLs.map { url in
                                                .default(Text(getQuality(url: url))
                                                ) {
                                                    startDownload(downloadURL: url)
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
    var media: Media
    @State private var isPlaying: Bool = false
    @State private var player: AVPlayer?
    //= AVPlayer(url: URL(string: "https://video.twimg.com/amplify_video/1730346441280016384/pl/RC5_ujzaEDw5zfJh.m3u8?tag=14&container=fmp4")!)
    
    var body: some View {
        let videoArray = media.videoInfo?.variants?.filter({ $0.url?.contains("m3u8") == false })
        let isPhoto = media.type?.contains("photo")
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
                .disabled(isPhoto ?? false)
                .opacity(isPhoto == true ? 0 : 1)
                
            } else {
                WebImage(url: URL(string: media.mediaURLHTTPS ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Button(action: {
                    // Videoyu oynatma işlemleri buraya eklenecek
                    player = AVPlayer(url: URL(string:  videoArray?.first?.url ?? "")!)
                    player?.seek(to: .zero)
                    player?.isMuted = false
                    player?.volume = 1
                    player?.play()
                    self.isPlaying = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height / 2)
                }
                .disabled(isPhoto ?? false)
                .opacity(isPhoto == true ? 0 : 1)
                
                
            }
                
        }
        .frame(maxWidth: .infinity)
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        let media = Media(displayURL: "http://display.url", expandedURL: "https://expanded.url", mediaURLHTTPS: "https://pbs.twimg.com/amplify_video_thumb/1730346441280016384/img/x62JpvlUS_3TC8fM.jpg", type: "video", url: "https://t.co/dP0xZwhCu3", videoInfo: VideoInfo(aspectRatio: [9,16], durationMillis: 21666, variants: [
            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/720x1280/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 2176000),
            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/320x568/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 632000),
            Variant(contentType: "video/mp4", url: "https://video.twimg.com/amplify_video/1730346441280016384/vid/avc1/480x852/pql7Uuw2pWCiCuXz.mp4?tag=14", bitrate: 950000)
            ]))
        
        let twitterMedia: TwitterMediaModel? = TwitterMediaModel(data: DataClass(tweetResult: TweetResult(result: Result(legacy: Legacy(entities: Entities(media: [media,media]), fullText: "Deneme")))))
        DownloadView(twitterMedia: twitterMedia)
    }
}
