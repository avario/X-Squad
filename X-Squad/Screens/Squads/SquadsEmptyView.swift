//
//  SquadsEmptyView.swift
//  X-Squad
//
//  Created by Avario on 17/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadsEmptyView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let label = UILabel()
		label.numberOfLines = 0
		label.text = "You don't have any squads setup.\nUse the + button in the top right corner to create a new squad."
		label.textAlignment = .center
		label.textColor = UIColor.white.withAlphaComponent(0.5)
		
		addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
		label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
		label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
		label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
