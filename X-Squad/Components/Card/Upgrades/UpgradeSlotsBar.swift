//
//  UpgradeSlotsBar.swift
//  X-Squad
//
//  Created by Avario on 18/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class UpgradeSlotsBar: UIView {
	
	init(upgradSlots: [Upgrade.UpgradeType]) {
		super.init(frame: .zero)
		
		let scrollView = UIScrollView()
		addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.contentInset.left = 20
		scrollView.contentInset.right = 20
		
		let upgradeBar = UIStackView()
		upgradeBar.translatesAutoresizingMaskIntoConstraints = false
		upgradeBar.axis = .horizontal
		scrollView.addSubview(upgradeBar)
		
		if upgradSlots.count <= 6 {
			upgradeBar.spacing = 5
		}
		
		upgradeBar.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		upgradeBar.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		upgradeBar.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		upgradeBar.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		upgradeBar.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
		
		for upgrade in upgradSlots {
			let upgradeButton = UpgradeButton()
			upgradeButton.isUserInteractionEnabled = false
			upgradeButton.upgradeType = upgrade
			
			upgradeBar.addArrangedSubview(upgradeButton)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	let fadePercentage: Double = 0.1
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let transparent = UIColor.clear.cgColor
		let opaque = UIColor.black.cgColor

		let maskLayer = CALayer()
		maskLayer.frame = self.bounds

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: bounds.size.width, height: bounds.size.height)
		gradientLayer.colors = [opaque, opaque, transparent]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		gradientLayer.locations = [0, NSNumber(floatLiteral: 1 - fadePercentage), 1]

		maskLayer.addSublayer(gradientLayer)
		layer.mask = maskLayer
	}
	
}
