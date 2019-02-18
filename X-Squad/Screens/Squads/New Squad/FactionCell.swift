//
//  FactionCell.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This cell displays a faction that the user can select on the "New Squad" screen.

import Foundation
import UIKit

class FactionCell: UITableViewCell {
	
	static let reuseIdentifier = "FactionCell"
	
	let iconLabel = UILabel()
	let nameLabel = UILabel()
	
	var faction: Faction? {
		didSet {
			guard let faction = faction else {
				return
			}
			
			iconLabel.text = faction.characterCode
			nameLabel.text = faction.rawValue
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = .clear
		backgroundColor = UIColor(white: 0.05, alpha: 1.0)
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(white: 0.20, alpha: 1.0)
		selectedBackgroundView = backgroundView
		
		contentView.addSubview(iconLabel)
		iconLabel.textAlignment = .center
		iconLabel.translatesAutoresizingMaskIntoConstraints = false
		iconLabel.textColor = UIColor(named: "XRed")
		iconLabel.font = UIFont.xWingIcon(32)
		
		iconLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		iconLabel.widthAnchor.constraint(equalToConstant: 66).isActive = true
		iconLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		contentView.addSubview(nameLabel)
		nameLabel.textColor = .white
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		
		nameLabel.leftAnchor.constraint(equalTo: iconLabel.rightAnchor).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
