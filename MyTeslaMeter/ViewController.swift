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
import Charts

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

class  MainViewController: UIViewController, ChartViewDelegate {
		@IBOutlet weak var xLabel: UILabel!

	@IBOutlet weak var yLabel: UILabel!
	@IBOutlet weak var zLabel: UILabel!
	@IBOutlet weak var magneticHeadingLabel: UILabel!
	@IBOutlet weak var headingAccuracyLabel: UILabel!
	@IBOutlet weak var magnitudeLabel: UILabel!
	
	@IBOutlet weak var timestampLabel: UILabel!
	
    @IBOutlet weak var lineChartView: LineChartView!
    
    // odczytuje pole magnetyczne
    let magneto = Magnetometer()
    
    var counter = 0
    var dataEntries: [ChartDataEntry] = []
	
	var serverIP = "0.0.0.0"
	
	var xLineColor: UIColor? {
		get {
			let dataSet = lineChartView.data!.dataSets[0] as! LineChartDataSet
			return dataSet.colorAt(dataSet.entryCount-1)
		}
		set {
			let dataSet = lineChartView.data!.dataSets[0] as! LineChartDataSet
			dataSet.setColor(newValue!)
		}
	}
	
	var yLineColor: UIColor? {
		get {
			let dataSet = lineChartView.data!.dataSets[1] as! LineChartDataSet
			return dataSet.colorAt(dataSet.entryCount-1)
		}
		set {
			let dataSet = lineChartView.data!.dataSets[1] as! LineChartDataSet
			dataSet.setColor(newValue!)
		}
	}
	var zLineColor: UIColor? {
		get {
			let dataSet = lineChartView.data!.dataSets[2] as! LineChartDataSet
			return dataSet.colorAt(dataSet.entryCount-1)
		}
		set {
			let dataSet = lineChartView.data!.dataSets[2] as! LineChartDataSet
			dataSet.setColor(newValue!)
		}
	}
	
    var biased = false
    
    //var lastSampleTime: UInt64 = 0
    //var timeBaseInfo : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.magneto.frequency = 0.02
        
        lineChartView.delegate = self
        setChart()
        //mach_timebase_info(&timeBaseInfo)
        //lastSampleTime = mach_absolute_time()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("view will disappear")
        self.magneto.stop()
    }
    
    override func viewWillAppear(animated: Bool) {
        if (!biased) {
            self.magneto.start {
                [weak self] data in
                if let _ = self {
                    /*
                    let thisSampleTime = mach_absolute_time()
                    let duration = (thisSampleTime - self!.lastSampleTime)
                    self!.majasLabel.text = (duration * UInt64(self!.timeBaseInfo.numer) / UInt64(self!.timeBaseInfo.denom) / 1_000_000).description
                    let frequency = 1000 / (duration * UInt64(self!.timeBaseInfo.numer) / UInt64(self!.timeBaseInfo.denom) / 1_000_000)
                    self!.timestampLabel.text = frequency.description + " Hz"
                    self!.lastSampleTime = thisSampleTime
                    */
                    if let deviceMotion = data {
                        let x = deviceMotion.magneticField.field.x
                        let y = deviceMotion.magneticField.field.y
                        let z = deviceMotion.magneticField.field.z
                        self?.updateChart(x, y: y, z: z)
                        let magnitude = sqrt(x*x + y*y + z*z)
                        self!.xLabel.text = x.format(14)
                        self!.yLabel.text = y.format(14)
                        self!.zLabel.text = z.format(14)
                        self!.magnitudeLabel.text = magnitude.format(14)
                        /*switch deviceMotion.magneticField.accuracy.rawValue {
                        case CMMagneticFieldCalibrationAccuracyUncalibrated.rawValue:
                        self!.headingAccuracyLabel.text = "Uncalibrated"
                        case CMMagneticFieldCalibrationAccuracyLow.rawValue:
                        self!.headingAccuracyLabel.text = "Low"
                        case CMMagneticFieldCalibrationAccuracyMedium.rawValue:
                        self!.headingAccuracyLabel.text = "Medium"
                        case CMMagneticFieldCalibrationAccuracyHigh.rawValue:
                        self!.headingAccuracyLabel.text = "High"
                        default:
                        self!.headingAccuracyLabel.text = "Unknown"
                        }
                        */}else {
                        print("wtf happened")
                    }
                }
            }
        }
        else {
            self.magneto.startBiased {
                [weak self] data in
                if let _ = self {
                    if let deviceMotion = data {
                        let x = deviceMotion.magneticField.x
                        let y = deviceMotion.magneticField.y
                        let z = deviceMotion.magneticField.z
                        self?.updateChart(x, y: y, z: z)
                        let magnitude = sqrt(x*x + y*y + z*z)
                        self!.xLabel.text = x.format(14)
                        self!.yLabel.text = y.format(14)
                        self!.zLabel.text = z.format(14)
                        self!.magnitudeLabel.text = magnitude.format(14)
                    }else {
                        print("wtf happened")
                    }
                }
            }
        }
    }
    
    func setChart() {
        lineChartView.noDataText = "no data text"
        lineChartView.descriptionText = ""
        lineChartView.getAxis(ChartYAxis.AxisDependency.Left).enabled = false
        let xChartDataSet = LineChartDataSet(yVals: [], label: "X axis")
        xChartDataSet.drawCirclesEnabled = false
        xChartDataSet.setColor(UIColor.blueColor())
        let yChartDataSet = LineChartDataSet(yVals: [], label: "Y axis")
        yChartDataSet.drawCirclesEnabled = false
        yChartDataSet.setColor(UIColor.redColor())
        let zChartDataSet = LineChartDataSet(yVals: [], label: "Z axis")
        zChartDataSet.drawCirclesEnabled = false
        zChartDataSet.setColor(UIColor.greenColor())
        
        let chartData = LineChartData(xVals: [String]())
        chartData.addDataSet(xChartDataSet)
        chartData.addDataSet(yChartDataSet)
        chartData.addDataSet(zChartDataSet)
        lineChartView.data = chartData
        
        lineChartView.setScaleEnabled(false)
        
    }
    
    func updateChart(x: Double, y: Double, z: Double) {
        let dataSetX = lineChartView.data!.dataSets[0] as! LineChartDataSet
        let dataSetY = lineChartView.data!.dataSets[1] as! LineChartDataSet
        let dataSetZ = lineChartView.data!.dataSets[2] as! LineChartDataSet
        updateDataSet(dataSetX, val: x)
        updateDataSet(dataSetY, val: y)
        updateDataSet(dataSetZ, val: z)
        
        let chartData = lineChartView.data!
        
        
        let YRight : ChartYAxis = lineChartView.getAxis(ChartYAxis.AxisDependency.Right)
        YRight.resetCustomAxisMax()
        YRight.resetCustomAxisMin()
        // lineChartView.scaleYEnabled = true
        //let maxi = max(x, y, z)
        //let mini = min(x, y, z)
        
        //lineChartView.setVisibleYRangeMaximum(CGFloat(500), axis: YRight.axisDependency)
        //lineChartView.moveViewToY(CGFloat((x+y+z)/3), axis: YRight.axisDependency)
        lineChartView.setVisibleXRangeMaximum(CGFloat(100))
        lineChartView.moveViewToX(chartData.xValCount - 100)
        //lineChartView.setScaleEnabled(true)
        //lineChartView.moveViewToY(CGFloat(maxi), axis: YRight.axisDependency)
        //lineChartView.moveViewTo(xIndex: chartData.xValCount - 100, yValue: CGFloat(maxi), axis: YRight.axisDependency)
        lineChartView.notifyDataSetChanged()
        YRight.setLabelCount(30, force: false)
        //        YRight.customAxisMax = maxi
        //      YRight.customAxisMin = mini
        
        
        
    }
    
    private func updateDataSet(dataSet: LineChartDataSet, val: Double) {
        
        lineChartView.data!.removeDataSet(dataSet)
        let dataEntry = ChartDataEntry(value: val, xIndex: counter++)
        let chartData = lineChartView.data!
        //dataSet.axisDependency = ChartYAxis.AxisDependency.Left
        dataSet.lineWidth = 3.0
        
        if dataSet.entryCount > 100 {
            dataSet.removeEntry(xIndex: 0)
            //chartData.removeEntryByXIndex(0, dataSetIndex: index)
        }
        chartData.addXValue("")
        dataSet.addEntry(dataEntry)
        chartData.addDataSet(dataSet)
        chartData.setDrawValues(false)
    }
}
