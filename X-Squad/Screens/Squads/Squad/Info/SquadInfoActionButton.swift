//
//  SquadInfoActionButton.swift
//  X-Squad
//
//  Created by Avario on 22/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadInfoActionButton: UIButton {
	
	let action: SquadInfoAction
	
	init(action: SquadInfoAction) {
		self.action = action
		
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		heightAnchor.constraint(equalToConstant: 56).isActive = true
		
		let actionImageView = UIImageView(image: action.image)
		addSubview(actionImageView)
		actionImageView.isUserInteractionEnabled = false
		actionImageView.translatesAutoresizingMaskIntoConstraints = false
		actionImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		actionImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		let textLabel = UILabel()
		addSubview(textLabel)
		textLabel.isUserInteractionEnabled = false
		textLabel.text = action.title
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		textLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		textLabel.leftAnchor.constraint(equalTo: actionImageView.rightAnchor, constant: 12).isActive = true
				
		let separator = UIView()
		separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		addSubview(separator)
		
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
		separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
		separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		switch action.type {
		case .action(_, let destructive):
			actionImageView.tintColor = destructive ? UIColor(named: "XRed") : UIColor.white.withAlphaComponent(0.75)
			textLabel.textColor = destructive ? UIColor(named: "XRed") : UIColor.white.withAlphaComponent(0.75)
			
		case .toggle(_, let isOn):
			actionImageView.tintColor = UIColor.white.withAlphaComponent(0.75)
			textLabel.textColor = UIColor.white.withAlphaComponent(0.75)
			
			let toggleSwitch = UISwitch()
			addSubview(toggleSwitch)
			toggleSwitch.isOn = isOn
			toggleSwitch.onTintColor = UIColor(named: "XRed")
			toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
			
			toggleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
			toggleSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
			
			toggleSwitch.addTarget(self, action: #selector(switchDidToggle(toggle:)), for: .valueChanged)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var isHighlighted: Bool {
		didSet {
			if case .action = action.type {
				backgroundColor = isHighlighted ? UIColor.black.withAlphaComponent(0.2) : .clear
			}
		}
	}
	
	@objc func switchDidToggle(toggle: UISwitch) {
		if case let .toggle(callback, _) = action.type {
			callback(toggle.isOn)
		}
	}
	
}
