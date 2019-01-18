//
//  SquadHeaderView.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadHeaderView: UIView {
	
	let squad: Squad
	let infoButton = UIButton(type: .infoDark)
	let costView = CostView()
	
	init(squad: Squad) {
		self.squad = squad
		super.init(frame: .zero)
	
		translatesAutoresizingMaskIntoConstraints = false
		heightAnchor.constraint(equalToConstant: 24).isActive = true
		
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoButton)
		
		infoButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
		infoButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		costView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(costView)
		
		costView.rightAnchor.constraint(equalTo: infoButton.leftAnchor, constant: -10).isActive = true
		costView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		updateCost()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateCost), name: .squadStoreDidUpdateSquad, object: squad)
	}
	
	@objc func updateCost() {
		costView.cost = String(squad.cost)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
