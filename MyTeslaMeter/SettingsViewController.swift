//
//  SettingsViewController.swift
//  MyTeslaMeter
//
//  Created by Paweł Kapica on 22/10/15.
//  Copyright © 2015 Paweł Kapica. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var serverIPField: UITextField!
	@IBOutlet weak var deviceNameField: UITextField!
	
	@IBOutlet weak var frequencyPicker: UIPickerView!
	
	@IBOutlet weak var xAxisColorPicker: UIPickerView!
	@IBOutlet weak var yAxisColorPicker: UIPickerView!
	@IBOutlet weak var zAxisColorPicker: UIPickerView!
	
	private let frequencyPickerData = [0.5, 1, 5, 10, 20, 50]
	
	private let defaults = NSUserDefaults.standardUserDefaults()
	
	private let colors = [
		"black" : UIColor.blackColor(),
		"white" : UIColor.whiteColor(),
		"red"	: UIColor.redColor(),
		"green" : UIColor.greenColor(),
		"blue"	: UIColor.blueColor(),
		"orange": UIColor.orangeColor(),
		"magenta":	UIColor.magentaColor(),
		"purple": UIColor.purpleColor()
	]

	var mainViewController: MainViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		
		mainViewController = self.tabBarController?.viewControllers?[0] as? MainViewController
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
		tapGestureRecognizer.cancelsTouchesInView = false
		
		self.view.addGestureRecognizer(tapGestureRecognizer)
		
		serverIPField.delegate = self
		deviceNameField.delegate = self
		
		frequencyPicker.delegate = self
		frequencyPicker.dataSource = self
		
		xAxisColorPicker.delegate = self
		xAxisColorPicker.dataSource = self
		
		yAxisColorPicker.delegate = self
		yAxisColorPicker.dataSource = self
		
		zAxisColorPicker.delegate = self
		zAxisColorPicker.dataSource = self
		
		loadSettings()
	}
	
	
	//MARK: UIPickerView functions
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == frequencyPicker {
			return frequencyPickerData.count
		} else if pickerView == xAxisColorPicker || pickerView == yAxisColorPicker || pickerView == zAxisColorPicker {
			return colors.count
		}
		return 0
	}
	
	func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
		let label = UILabel()
		label.textColor = UIColor.blackColor()
		label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		label.textAlignment = NSTextAlignment.Center
		if pickerView == frequencyPicker {
			let value = frequencyPickerData[row]
			label.text = (value >= 1) ? value.format(0) : value.description
		} else if pickerView == xAxisColorPicker || pickerView == yAxisColorPicker || pickerView == zAxisColorPicker {
			let colorsArray = [String](colors.keys)
			label.textColor = colors[colorsArray[row]]
			label.text = colorsArray[row]
		}
		return label
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == frequencyPicker {
			defaults.setInteger(row, forKey: "frequency")
			mainViewController?.magneto.frequency = frequencyPickerData[row]
			print("setting frequency value: ", frequencyPickerData[row])
		} else if pickerView == xAxisColorPicker || pickerView == yAxisColorPicker || pickerView == zAxisColorPicker {
			var key = ""
			let colorsArray = [UIColor](colors.values)
			if pickerView == xAxisColorPicker {
				key = "xAxisColor"
				mainViewController?.xLineColor = colorsArray[row]
				print("setting x axis color: ", colorsArray[row])
			} else if pickerView == yAxisColorPicker {
				key = "yAxisColor"
				mainViewController?.yLineColor = colorsArray[row]
				print("setting y axis color: ", colorsArray[row])
			} else if pickerView == zAxisColorPicker {
				key = "zAxisColor"
				mainViewController?.zLineColor = colorsArray[row]
				print("setting z axis color: ", colorsArray[row])
			}
			defaults.setInteger(row, forKey: key)
		}
	}
	
	//MARK: UITextField functions
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		if textField == serverIPField {
			defaults.setObject(serverIPField.text!, forKey: "serverIP")
			mainViewController?.serverIP = serverIPField.text!
		} else if textField == deviceNameField {
			defaults.setObject(deviceNameField.text!, forKey: "deviceName")
		}
	}
	
	func hideKeyboard() {
		self.view.endEditing(true)
	}
	
	override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		hideKeyboard()
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		print("touchesBegan")
	}

	//MARK: Private functions
	private func loadSettings() {
		serverIPField.text = defaults.stringForKey("serverIP")
		deviceNameField.text = defaults.stringForKey("deviceName")
		
		let freq = defaults.integerForKey("frequency")
		frequencyPicker.selectRow(freq, inComponent: 0, animated: false)
		
		let xAxisColor = defaults.integerForKey("xAxisColor")
		xAxisColorPicker.selectRow(xAxisColor, inComponent: 0, animated: false)
		
		let yAxisColor = defaults.integerForKey("yAxisColor")
		yAxisColorPicker.selectRow(yAxisColor, inComponent: 0, animated: false)
		
		let zAxisColor = defaults.integerForKey("zAxisColor")
		zAxisColorPicker.selectRow(zAxisColor, inComponent: 0, animated: false)
		
	}
}
