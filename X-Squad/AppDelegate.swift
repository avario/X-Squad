//
//  AppDelegate.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
//		for family in UIFont.familyNames.sorted() {
//			let names = UIFont.fontNames(forFamilyName: family)
//			print("Family: \(family) Font names: \(names)")
//		}
		
//		#warning("Clear chache")
//		let cache = ImageCache.default
//		cache.clearMemoryCache()
//		cache.clearDiskCache { print("Done") }
		
		UIView.appearance().tintColor = UIColor(named: "XRed")
		UIView.appearance(whenContainedInInstancesOf: [DarkNavigationBar.self]).tintColor = UIColor.white.withAlphaComponent(0.5)
		
		window = UIWindow(frame: UIScreen.main.bounds)
		
		if CardStore.needsUpdate {
			let updateCardsViewController = UpdateCardsViewController()
			window?.rootViewController = updateCardsViewController
			updateCardsViewController.update(dismissOnCompletion: false)
		} else {
			let darkNavigation = UINavigationController(navigationBarClass: DarkNavigationBar.self, toolbarClass: nil)
			darkNavigation.viewControllers = [_HomeViewController()]
			window?.rootViewController = darkNavigation
		}
		
		window?.makeKeyAndVisible()
		
		return true
	}
	
}

