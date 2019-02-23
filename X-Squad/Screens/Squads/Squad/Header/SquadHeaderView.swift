//
//  SquadHeaderView.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This view shows a header for the Squad view with a Close button, point cost, and Info button.

import Foundation
import UIKit

class SquadHeaderView: UIView {
	
	let squad: Squad
	let infoButton = UIButton(type: .infoDark)
	let costView = CostView()
	let closeButton = SmallButton()
	let hyperspaceLabel = UILabel()
	
	init(squad: Squad) {
		self.squad = squad
		super.init(frame: .zero)
	
		translatesAutoresizingMaskIntoConstraints = false
		heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setTitle("Close", for: .normal)
		
		addSubview(closeButton)
		closeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
		closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoButton)
		
		infoButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
		infoButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		infoButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		infoButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
		
		costView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(costView)
		
		costView.rightAnchor.constraint(equalTo: infoButton.leftAnchor, constant: 0).isActive = true
		costView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		updateCost()
		
		hyperspaceLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		hyperspaceLabel.font = UIFont.systemFont(ofSize: 12)
		hyperspaceLabel.text = "H"
		hyperspaceLabel.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(hyperspaceLabel)
		hyperspaceLabel.rightAnchor.constraint(equalTo: costView.leftAnchor, constant: -10).isActive = true
		hyperspaceLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		hyperspaceLabel.isHidden = !squad.isHyperspaceOnly
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateCost), name: .squadStoreDidUpdateSquad, object: squad)
	}
	
	@objc func updateCost() {
		costView.cost = squad.pointCost
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
