//
//  xDownApp.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 16.11.2023.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct xDownApp: App {
    init() {
        //MARK: ADMOB
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            //User has not indicated their choice for app tracking
            //You may want to show a pop-up explaining why you are collecting their data
            //Toggle any variables to do this here
        } else {
            ATTrackingManager.requestTrackingAuthorization { status in
                //Whether or not user has opted in initialize GADMobileAds here it will handle the rest
                                                            
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
    }
    @Environment(\.scenePhase) private var scenePhase
    @State private var appOpenAd = AppOpenAd()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    //Arka plandan ön plana geçince reklamı göster.
                    appOpenAd.showAd()
                }
        }
    }
}

