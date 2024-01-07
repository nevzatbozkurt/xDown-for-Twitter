//
//  Other.swift
//  basic iptv
//
//  Created by Nevzat BOZKURT on 10.10.2022.
//

import UIKit
import SwiftUI

let screen = UIScreen.main.bounds
let isIpad = UIDevice.current.userInterfaceIdiom == .pad

#if DEBUG
    let adUnitIdintersitial: String = "ca-app-pub-3940256099942544/4411468910" //TEST
    let adUnitIdBanner: String = "ca-app-pub-3940256099942544/2934735716" //TEST
    let addUnitIdOpenApp: String = "ca-app-pub-3940256099942544/9257395921" //TEST
#else
    let adUnitIdintersitial: String = "ca-app-pub-1121633397436094/3717531924" //Admob
    let adUnitIdBanner: String = "ca-app-pub-1121633397436094/2174964519" //Admob
    let addUnitIdOpenApp: String = "ca-app-pub-1121633397436094/8233956461" //Admob
#endif
