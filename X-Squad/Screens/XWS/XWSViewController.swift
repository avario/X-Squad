//
//  XWSViewController.swift
//  X-Squad
//
//  Created by Avario on 24/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class XWSViewController: UIViewController {
	
	enum Action {
		case `import`
		case export
	}
	
	let action: Action
	
	init(action: Action) {
		self.action = action
		super.init(nibName: nil, bundle: nil)
		
		switch action {
		case .import:
			title = "Import XWS"
		case .export:
			title = "Export XWS"
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
