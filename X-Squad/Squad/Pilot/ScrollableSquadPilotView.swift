//
//  ScrollableSquadPilotView.swift
//  X-Squad
//
//  Created by Avario on 16/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class ScrollableSquadPilotView: UIScrollView {
	
	let squadPilotView: SquadPilotView

	init(pilot: Squad.Pilot) {
		self.squadPilotView = SquadPilotView(pilot: pilot, height: UIScreen.main.bounds.width * 0.75, isEditing: true)
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = false
		alwaysBounceHorizontal = true
		showsHorizontalScrollIndicator = false
		addSubview(squadPilotView)
		
		squadPilotView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
		squadPilotView.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor, constant: -16).isActive = true
		squadPilotView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor).isActive = true
		squadPilotView.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor, constant: 16).isActive = true
		
		frameLayoutGuide.heightAnchor.constraint(equalTo: squadPilotView.heightAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
