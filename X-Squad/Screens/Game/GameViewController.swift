//
//  GameViewController.swift
//  X-Squad
//
//  Created by Avario on 09/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays a current game (with the user's squad and a timer).

import Foundation
import UIKit

class GameViewController: UITableViewController {
	
	let game: Game
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	init(game: Game) {
		self.game = game
		
		super.init(style: .grouped)
		
		title = "Game"
		tabBarItem = UITabBarItem(title: "Game", image: UIImage(named: "Game Tab"), selectedImage: nil)
		
		navigationItem.hidesBackButton = true
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End", style: .plain, target: self, action: #selector(endGame))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "XBackground")
		
		definesPresentationContext = true
		
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = SquadCell.rowHeight
		tableView.tableFooterView = UIView()
		
		tableView.register(SquadCell.self, forCellReuseIdentifier: SquadCell.reuseIdentifier)
		
		let timerView = TimerView()
		tableView.tableFooterView = timerView
	}
	
	@objc func endGame() {
		self.navigationController?.popToRootViewController(animated: true)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let squadCell = tableView.dequeueReusableCell(withIdentifier: SquadCell.reuseIdentifier) as! SquadCell
		squadCell.squad = game.squad
		
		return squadCell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Squad"
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let squadViewController = GameSquadViewControler(for: game.squad, states: game.memberStates)
		tabBarController!.present(squadViewController, animated: true, completion: nil)
	}
	
}
