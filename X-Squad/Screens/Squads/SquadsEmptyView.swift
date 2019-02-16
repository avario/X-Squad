//
//  SquadsEmptyView.swift
//  X-Squad
//
//  Created by Avario on 17/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This view is shown on the Squads screen when the user has no squads.

import Foundation
import UIKit

class SquadsEmptyView: UIView {
	
	init(message: String) {
		super.init(frame: .zero)
		
		let label = UILabel()
		label.numberOfLines = 0
		label.text = message
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
