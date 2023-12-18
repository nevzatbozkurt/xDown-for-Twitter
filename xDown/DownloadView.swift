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
    @State private var isPlaying: Bool = false
    var twitterMedia: TwitterMediaModel?
    
    var body: some View {
        VStack {
            if let medias = twitterMedia?.data?.tweetResult?.result?.legacy?.entities?.media {
                // Yukarıdaki yarıda fotoğraf ve oynatma butonu
                
                TabView {
                    ForEach(medias) { media in
                        
                        MediaItem(media: media, isPlaying: $isPlaying)

                    }
                }
              
                .tabViewStyle(.page)
                
               
                
                VStack {
                   
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                            .frame(width: 90, height: 90)
                            .padding(0)
                        
                        Text("Download to Gallery")
                            .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))

                        
                    }.padding(.horizontal)
                    
                    
                }
                .padding(.bottom)
                
                
                
            } else {
                Text("Video veya fotoğraf bulunamadı.")
            }
            
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        
        
    }
}


struct MediaItem: View {
    var media: Media
    @Binding var isPlaying: Bool
    @State private var player: AVPlayer?
    //= AVPlayer(url: URL(string: "https://video.twimg.com/amplify_video/1730346441280016384/pl/RC5_ujzaEDw5zfJh.m3u8?tag=14&container=fmp4")!)
    
    var body: some View {
        let videoArray = media.videoInfo?.variants?.filter({ $0.url?.contains("m3u8") == false })
        
        ZStack(alignment: .center) {
            if (isPlaying && player != nil) {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
                    
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
                    self.isPlaying = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
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
