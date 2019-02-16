//
//  ScanViewController.swift
//  X-Squad
//
//  Created by Avario on 25/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen shows a camera view that can be used to scan XWS QR codes.

import Foundation
import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	private let videoPreviewLayer: AVCaptureVideoPreviewLayer
	
	let captureSession = AVCaptureSession()
	private let captureMetadataOutput = AVCaptureMetadataOutput()
	private let metadata: [AVMetadataObject.ObjectType] = [.qr]
	
	init() {
		self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		super.init(nibName: nil, bundle: nil)
		
		title = "Scan XWS QR Code"
		navigationItem.largeTitleDisplayMode = .never
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "XBackground")
		
		let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
		
		guard let captureDevice = deviceDiscoverySession.devices.first else {
			return
		}
		
		do {
			let input = try AVCaptureDeviceInput(device: captureDevice)
			captureSession.addInput(input)
			
			let captureMetadataOutput = AVCaptureMetadataOutput()
			captureSession.addOutput(captureMetadataOutput)
			
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
		} catch {
			return
		}
		
		videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		videoPreviewLayer.frame = view.layer.bounds
		view.layer.addSublayer(videoPreviewLayer)
		
		captureSession.startRunning()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		videoPreviewLayer.frame = view.layer.bounds
	}
	
	var didFindSquad = false
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		// Whenever data is detected in the camera view, check if it's a QR code and that the data can be decoded into an XWS object.
		guard didFindSquad == false,
			let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
			metadata.type == AVMetadataObject.ObjectType.qr,
			let text = metadata.stringValue,
		 	let data = text.data(using: .utf8),
			let xws = try? JSONDecoder().decode(XWS.self, from: data) else {
			return
		}
		
		// This is just set to make sure QR codes are not scanned more than once.
		didFindSquad = true
		
		let squad = Squad(xws: xws)
		SquadStore.add(squad: squad)
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		let tabViewController = self.presentingViewController!
		
		dismiss(animated: true) {
			let squadViewController = EditSquadViewController(for: squad)
			tabViewController.present(squadViewController, animated: true, completion: nil)
		}
	}
	
}
