//
//  SquadCell.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadCell: UITableViewCell {
	
	static let reuseIdentifier = "SquadCell"
	static let rowHeight: CGFloat = 80
	
	var squad: Squad? {
		didSet {
			NotificationCenter.default.removeObserver(self)
			
			guard let squad = squad else {
				return
			}
			
			iconLabel.text = squad.faction.characterCode
			updatePilotViews()
			
			NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidAddPilotToSquad, object: squad)
			NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidRemovePilotFromSquad, object: squad)
		}
	}
	
	let iconLabel = UILabel()
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	var emptyLabel: UILabel?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .black
		contentView.backgroundColor = .clear
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(white: 0.20, alpha: 1.0)
		selectedBackgroundView = backgroundView
		
		contentView.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceHorizontal = true
		scrollView.isUserInteractionEnabled = false
		contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
		
		scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
		
		scrollView.addSubview(iconLabel)
		iconLabel.textAlignment = .center
		iconLabel.translatesAutoresizingMaskIntoConstraints = false
		iconLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		iconLabel.font = UIFont.xWingIcon(32)
		
		iconLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		iconLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
		iconLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
		iconLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		scrollView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = 10
		
		stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
		stackView.leftAnchor.constraint(equalTo: iconLabel.rightAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	func updateEmptyLabel() {
		if let squad = squad, squad.pilots.isEmpty, emptyLabel == nil {
			emptyLabel = UILabel()
			emptyLabel?.translatesAutoresizingMaskIntoConstraints = false
			emptyLabel?.textAlignment = .center
			emptyLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
			emptyLabel?.font = UIFont.systemFont(ofSize: 14)
			emptyLabel?.numberOfLines = 0
			emptyLabel?.text = "This squad is empty.\nTap here to edit."
			
			contentView.addSubview(emptyLabel!)
			emptyLabel?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
			emptyLabel?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			emptyLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -44).isActive = true
			emptyLabel?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 44).isActive = true
		} else if let emptyLabel = emptyLabel {
			emptyLabel.removeFromSuperview()
			self.emptyLabel = nil
		}
	}
	
	var pilotViews: [PilotView] = []
	
	@objc func updatePilotViews() {
		guard let squad = squad else {
			return
		}
		
		updateEmptyLabel()
		
		func pilotView(for pilot: Squad.Pilot) -> PilotView {
			if let existingPilotView = pilotViews.first(where: { $0.pilot.uuid == pilot.uuid }) {
				return existingPilotView
			} else {
				let squadPilotView = PilotView(pilot: pilot, height: SquadCell.rowHeight, isEditing: false)
				pilotViews.append(squadPilotView)
				
				return squadPilotView
			}
		}
		
		// Remove any pilots that are no longer in the squad
		for pilotView in pilotViews {
			if !squad.pilots.contains(where: { $0.uuid == pilotView.pilot.uuid }) {
				pilotView.removeFromSuperview()
			}
		}
		pilotViews = pilotViews.filter({ $0.superview != nil })
		
		for (index, pilot) in squad.pilots.enumerated() {
			let squadPilotView = pilotView(for: pilot)
			stackView.insertArrangedSubview(squadPilotView, at: index)
		}
	}
	
}
