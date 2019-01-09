//
//  DarkNavigationBar.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class DarkNavigationBar: UINavigationBar {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		barStyle = .black
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
