//
//  UpgradeButton.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// A simple button that displays the icon for an upgrade slot.

import Foundation
import UIKit

class UpgradeButton: UIButton {
	
	var upgradeType: Upgrade.UpgradeType? {
		didSet {
			setTitle(upgradeType?.characterCode, for: .normal)
		}
	}
	
	var associatedUpgrade: Upgrade?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setTitleColor(UIColor.white.withAlphaComponent(0.5), for:.normal)
		setTitleColor(.white, for: .highlighted)
		titleLabel?.font = UIFont.xWingIcon(28)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 32, height: 28)
	}
	
}
