//
//  InterstitialAd.swift
//  Wordies
//
//  Created by Nevzat BOZKURT on 15.05.2022.
//

import GoogleMobileAds

class AppOpenAd: NSObject, GADFullScreenContentDelegate {
    var openAd: GADAppOpenAd?
    var unitId: String = addUnitIdOpenApp
    
    //Want to have one instance of the ad for the entire app
    //We can do this b/c you will never show more than 1 ad at once so only 1 ad needs to be loaded
    //static let shared = InterstitialAd()
  
    override init() {
        super.init()
        loadAd()
        
        print("LOG: reklam yükle openAd")
        
    }
    
    func loadAd() {
        let req = GADRequest()
        req.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        //Reklam sesini kısıyoruz. Bazen arka planda ses yapıyor o yüzden.
        GADMobileAds.sharedInstance().applicationVolume = 0.0
        
        GADAppOpenAd.load(withAdUnitID: unitId, request: req) { [self] openAd, err in
            if let err = err {
                print("Failed to load ad with error: \(err)")
                //return
            }
            self.openAd = openAd
            self.openAd?.fullScreenContentDelegate = self
        }
    }
    
    //Presents the ad if it can, otherwise dismisses so the user's experience is not interrupted
    func showAd() {
        //Reklam sesini açıyoruz.
        GADMobileAds.sharedInstance().applicationVolume = 1.0
        
        if let ad = openAd, let root = UIApplication.shared.windows.first?.rootViewController {
            ad.present(fromRootViewController: root)
        } else {
            print("Ad not ready")
            //isPresented = false
            //Prepares another ad for the next time view presented
            self.loadAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //Prepares another ad for the next time view presented
        self.loadAd()
        print("Ad Closed")
        //Dismisses the view once ad dismissed
        //isPresented = false
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad Error")
        //Hata verdiğinde tekrar reklam yüklenmesini sağlıyoruz. Telefon yatay dikey mod arasında değişiklik olunca buradan hataya düşüyor genelde.
        self.loadAd()
        //isPresented = false
    }

    
}
