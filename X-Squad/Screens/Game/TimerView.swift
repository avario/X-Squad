//
//  TimerView.swift
//  X-Squad
//
//  Created by Avario on 14/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This view displays the timer used on the Game screen (the minutes/seconds remaining and a pause/resume button).

import Foundation
import UIKit

class TimerView: UIView {
	
	let minutesLabel = UILabel()
	let secondsLabel = UILabel()
	
	let button = XButton()
	
	var timer: Timer?
	var isTimerRunning = false
	
	var secondsRemaining = 60 * 75
	
	var secondsRemainingWhenTimerStarted = 60 * 75
	var timerStarted: Date?
	
	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
		
		minutesLabel.textAlignment = .right
		minutesLabel.textColor = .white
		minutesLabel.font = UIFont.systemFont(ofSize: 64, weight: .black)
		minutesLabel.text = "75"
		minutesLabel.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(minutesLabel)
		minutesLabel.rightAnchor.constraint(equalTo: centerXAnchor, constant: 10).isActive = true
		minutesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
		
		secondsLabel.textAlignment = .left
		secondsLabel.textColor = .white
		secondsLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
		secondsLabel.text = "00"
		secondsLabel.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(secondsLabel)
		secondsLabel.leftAnchor.constraint(equalTo: centerXAnchor, constant: 20).isActive = true
		secondsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
		
		button.setTitle("Start Game", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(button)
		button.heightAnchor.constraint(equalToConstant: 44).isActive = true
		button.widthAnchor.constraint(equalToConstant: 140).isActive = true
		button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
		
		// When the app foregrounds the time remaining must be updated because the timer will not fire when the app is backgrounded.
		NotificationCenter.default.addObserver(self, selector: #selector(updateTimeRemaining), name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// Pause/resume the timer.
	@objc func buttonPressed() {
		if isTimerRunning {
			timer?.invalidate()
			button.setTitle("Resume", for: .normal)
		} else {
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeRemaining), userInfo: nil, repeats: true)
		
			timerStarted = Date()
			secondsRemainingWhenTimerStarted = secondsRemaining
			
			button.setTitle("Pause", for: .normal)
		}
		
		isTimerRunning.toggle()
	}
	
	@objc func updateTimeRemaining() {
		guard let timerStarted = timerStarted else {
			return
		}
		
		let secondsElapsed = Date().timeIntervalSince(timerStarted)
		secondsRemaining = secondsRemainingWhenTimerStarted - Int(secondsElapsed)
		
		let minutes = Int(secondsRemaining) / 60
		let seconds = secondsRemaining % 60
		
		minutesLabel.text = String(format: "%02d", minutes)
		secondsLabel.text = String(format: "%02d", seconds)
	}

	
	
}
