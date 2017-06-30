//
//  AppDelegate.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //LaunchViewController -> HomeViewController -> PigLatinViewController (fragile but i don't expect it to change)
        if let pigLatinViewController = window?.rootViewController?.presentedViewController?.presentedViewController as? PigLatinViewController {
            //pig latin has to dismiss because going in background puts the timers out of sync with the audio
            pigLatinViewController.dismiss(animated: true, completion: nil)
        }
    }

}

