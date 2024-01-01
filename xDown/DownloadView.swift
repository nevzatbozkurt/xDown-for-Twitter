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
    var data: [DetailModel]
    @State private var isPresented = false
    @State private var selectedTab: Int = 0
    
    @StateObject private var videoDownloadVM = VideoDownloaderViewModel()
    
    func startDownload(downloadURL: String) {
        if let url = URL(string: downloadURL) {
            videoDownloadVM.downloadAndSaveMedia(fromURL: url) { success in
                print(success)
            }
        } else {
            //ERROR MESAJI VER
        }
    }
    
    var body: some View {
        VStack {
            if data.count > 0  {
                // Yukarıdaki yarıda fotoğraf ve oynatma butonu
                TabView(selection: $selectedTab) {
                    ForEach(data) { datum in
                        MediaItem(media: datum)
                            .tag(datum.id)
                    }
                }
                .tabViewStyle(.page)
                .disabled(videoDownloadVM.isDownloading)
                .onChange(of: selectedTab) { _ in
                    videoDownloadVM.progress = 0.00
                }
                
                if let err = videoDownloadVM.errorMsg {
                    Text(err)
                        .font(.headline)
                        .roundedStyle(backgroundColor: .red.opacity(0.5), cornerRadius: 8)
                    
                }
                
                //MARK: Download Button
                HStack {
                    //Eğer bir download işlemi tamamlandıysa.
                    if (videoDownloadVM.isDownloadComplated()) {
                        Button {
                            guard let url = URL(string: "photos-redirect://") else { return }
                            UIApplication.shared.open(url)
                        } label: {
                            Text("Galeriye Kayıt Edildi. Galeriyi Aç.")
                        }
                    } else {
                        downloadButton
                    }
                }
                .roundedStyle(backgroundColor: videoDownloadVM.isDownloadComplated() ? Color.green.opacity(0.66) :  Color.secondary.opacity(0.3))
                .padding(.horizontal)
                .padding(.bottom)
                .sheet(isPresented: $videoDownloadVM.showNeedAuthView) {
                    if #available(iOS 16.0, *) {
                        PermissionView()
                            .presentationDetents([.height(300)])
                    } else {
                        PermissionView()
                            
                    }
                }
            } else {
                Text("Video veya fotoğraf bulunamadı.")
            }
            
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.horizontal)
        .onDisappear() {
            print("LOG: onDisappear 2")
        }
    }

    
    @ViewBuilder
    private var downloadButton: some View {
        Button {
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
            
        } label: {
            Text(videoDownloadVM.isDownloading ? "Downloading: \(Int(videoDownloadVM.progress * 100))%" : "Download to Gallery")
        }
        .disabled(videoDownloadVM.isDownloading || videoDownloadVM.isDownloadComplated())
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
    }
    
}


struct PermissionView: View {
    var body: some View {
        Button {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        } label: {
            Text("Yetki yok yetki ver.")
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
                    //.aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.red)
                
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
