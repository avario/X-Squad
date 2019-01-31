//
//  SquadEmptyView.swift
//  X-Squad
//
//  Created by Avario on 25/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadEmptyView: UIView {
	
	init(faction: Faction) {
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		
		let factionIcon = UILabel()
		factionIcon.translatesAutoresizingMaskIntoConstraints = false
		factionIcon.font = UIFont.xWingIcon(56)
		factionIcon.textColor = UIColor.white.withAlphaComponent(0.25)
		factionIcon.textAlignment = .center
		factionIcon.text = faction.characterCode
		
		let emptyLabel = UILabel()
		emptyLabel.translatesAutoresizingMaskIntoConstraints = false
		emptyLabel.textAlignment = .center
		emptyLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		emptyLabel.font = UIFont.systemFont(ofSize: 16)
		emptyLabel.numberOfLines = 0
		emptyLabel.text = "This squad is empty."
		
		let stackView = UIStackView(arrangedSubviews: [factionIcon, emptyLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		
		addSubview(stackView)
		stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
		
		heightAnchor.constraint(equalToConstant: 160).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
