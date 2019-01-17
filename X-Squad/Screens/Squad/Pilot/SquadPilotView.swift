//
//  ScrollableSquadPilotView.swift
//  X-Squad
//
//  Created by Avario on 16/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadPilotView: UIScrollView {
	
	let pilotView: PilotView

	init(pilot: Squad.Pilot) {
		self.pilotView = PilotView(pilot: pilot, height: UIScreen.main.bounds.width * 0.75, isEditing: true)
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = false
		alwaysBounceHorizontal = true
		alwaysBounceVertical = false
		showsHorizontalScrollIndicator = false
		addSubview(pilotView)
		
		pilotView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
		pilotView.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor, constant: -16).isActive = true
		pilotView.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor, constant: 16).isActive = true
		
		frameLayoutGuide.heightAnchor.constraint(equalTo: pilotView.heightAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
