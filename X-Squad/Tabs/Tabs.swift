//
//  Tabs.swift
//  X-Squad
//
//  Created by Avario on 08/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class Tab: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(named: "XBackground")
	}
	
}

class GameTab: Tab {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.tabBarItem = UITabBarItem(title: "Game", image: UIImage(named: "Game Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class SquadsTab: Tab {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.tabBarItem = UITabBarItem(title: "Squads", image: UIImage(named: "Squads Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class SearchTab: Tab {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "Search Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class SettingsTab: Tab {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "Settings Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
