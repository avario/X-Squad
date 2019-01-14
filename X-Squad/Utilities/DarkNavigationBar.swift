//
//  DarkNavigationBar.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

// The main function of this class is to be able to apply a different tint color
// to navigation items through the appearance proxy.
class DarkNavigationBar: UINavigationBar {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		barStyle = .black
		prefersLargeTitles = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
