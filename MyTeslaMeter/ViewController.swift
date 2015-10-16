//
//  ViewController.swift
//  MyTeslaMeter
//
//  Created by Paweł Kapica on 08/10/15.
//  Copyright © 2015 Paweł Kapica. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

extension String
{
	func replace(target: String, withString: String) -> String
	{
		return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
	}
}

extension Double {
	func format(x: Int) -> String
	{
		let nf = NSNumberFormatter()
		nf.minimumFractionDigits = x
		nf.minimumIntegerDigits = 1
		return (nf.stringFromNumber(self)?.replace(",", withString: "."))!
	}
}

class ViewController: UIViewController, CLLocationManagerDelegate {
	
	@IBOutlet weak var xLabel: UILabel!
	@IBOutlet weak var yLabel: UILabel!
	@IBOutlet weak var zLabel: UILabel!
	@IBOutlet weak var magneticHeadingLabel: UILabel!
	@IBOutlet weak var headingAccuracyLabel: UILabel!
	@IBOutlet weak var magnitudeLabel: UILabel!
	
	@IBOutlet weak var timestampLabel: UILabel!
	
	@IBOutlet weak var majasLabel: UILabel!
	
	let locationManager = CLLocationManager()
	
	let motionManager = CMMotionManager()
	
	var lastSampleTime: UInt64 = 0
	var timeBaseInfo : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.locationManager.headingFilter = kCLHeadingFilterNone
		self.locationManager.delegate = self
		//self.locationManager.startUpdatingHeading()
		
		self.motionManager.accelerometerUpdateInterval = 0
		self.motionManager.gyroUpdateInterval = 0
		self.motionManager.magnetometerUpdateInterval = 0
		self.motionManager.deviceMotionUpdateInterval = 0.01
		
		//self.motionManager.startAccelerometerUpdates()
		//self.motionManager.startGyroUpdates()
		//self.motionManager.startMagnetometerUpdates()
		self.motionManager.startDeviceMotionUpdates()
		
		//self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handleAccelerometerData)
		//self.motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handleGyroData)
		//self.motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handleMagnetoData)
		//self.motionManager.startDeviceMotionUpdatesToQueue()
		self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XMagneticNorthZVertical, toQueue: NSOperationQueue.mainQueue(), withHandler: handleMotionData)
		
		mach_timebase_info(&timeBaseInfo)
		lastSampleTime = mach_absolute_time()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func handleAccelerometerData(data: CMAccelerometerData?, error: NSError?) {
		if let _ = error {
			print("error")
		} else if let accelerometerData = data {
			let x = accelerometerData.acceleration.x
			let y = accelerometerData.acceleration.y
			let z = accelerometerData.acceleration.z
			//print(x,y,z)
		} else {
			print("wtf happened")
		}
	}
	
	func handleGyroData(data: CMGyroData?, error: NSError?) {
		if let _ = error {
			print("error")
		} else if let gyroData = data {
			let x = gyroData.rotationRate.x
			let y = gyroData.rotationRate.y
			let z = gyroData.rotationRate.z
			//print(x,y,z)
		} else {
			print("wtf happened")
		}
	}
	
	func handleMagnetoData(data: CMMagnetometerData?, error: NSError?) {
		if let _ = error {
			print("error")
		} else if let magnetoData = data {
			/*
			let x = gyroData.rotationRate.x
			let y = gyroData.rotationRate.y
			let z = gyroData.rotationRate.z
			print(x,y,z)
			*/
		} else {
			print("wtf happened")
		}
	}
	
	func handleMotionData(data: CMDeviceMotion?, error: NSError?) {
		let thisSampleTime = mach_absolute_time()
		let duration = (thisSampleTime - lastSampleTime)
		self.majasLabel.text = (duration * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom) / 1_000_000).description
		let frequency = 1000 / (duration * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom) / 1_000_000)
		self.timestampLabel.text = frequency.description + " Hz"
		lastSampleTime = thisSampleTime
		if let _ = error {
			print("error")
		} else if let deviceMotion = data {
			let x = deviceMotion.magneticField.field.x
			let y = deviceMotion.magneticField.field.y
			let z = deviceMotion.magneticField.field.z
			let magnitude = sqrt(x*x + y*y + z*z)
			self.xLabel.text = x.format(14)
			self.yLabel.text = y.format(14)
			self.zLabel.text = z.format(14)
			self.magnitudeLabel.text = magnitude.format(14)
			switch deviceMotion.magneticField.accuracy.rawValue {
			case CMMagneticFieldCalibrationAccuracyUncalibrated.rawValue:
				self.headingAccuracyLabel.text = "Uncalibrated"
			case CMMagneticFieldCalibrationAccuracyLow.rawValue:
				self.headingAccuracyLabel.text = "Low"
			case CMMagneticFieldCalibrationAccuracyMedium.rawValue:
				self.headingAccuracyLabel.text = "Medium"
			case CMMagneticFieldCalibrationAccuracyHigh.rawValue:
				self.headingAccuracyLabel.text = "High"
			default:
				self.headingAccuracyLabel.text = "Unknown"
			}
		} else {
			print("wtf happened")
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		/*
		self.magneticHeadingLabel.text = newHeading.magneticHeading.format(13)
		if newHeading.headingAccuracy < 0 {
		self.headingAccuracyLabel.textColor = UIColor.redColor()
		} else {
		self.headingAccuracyLabel.textColor = UIColor.blackColor()
		}
		self.headingAccuracyLabel.text = newHeading.headingAccuracy.description
		*/
		/*
		let x = newHeading.x
		let y = newHeading.y
		let z = newHeading.z
		self.xLabel.text = x.format(13)
		self.yLabel.text = y.format(13)
		self.zLabel.text = z.format(13)
		let magnitude = sqrt(x*x + y*y + z*z)
		self.magnitudeLabel.text = magnitude.format(13)
		*/
	}
}
