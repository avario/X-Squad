//
//  SelectSquadViewController.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen allows the user to select a quad that they want to use in a game.

import Foundation
import UIKit

class SelectSquadViewController: SquadsViewController {
	
	init() {
		super.init(emptyMessage: "You don't have any squads setup.\nGo to the Squads tab to create a new squad.")
		
		title = "Select Squad"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let squad = SquadStore.shared.squads[indexPath.row]
		
		let game = Game(squad: squad)
		
		let gameViewController = GameViewController(game: game)
		navigationController?.pushViewController(gameViewController, animated: true)
	}
	
}
