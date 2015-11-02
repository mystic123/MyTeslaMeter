//
//  Magnetometer.swift
//  MyTeslaMeter
//
//  Created by Maja Zalewska on 28/10/15.
//  Copyright © 2015 Paweł Kapica. All rights reserved.
//

import UIKit
import CoreMotion
/**
 Posiada wszystkie funkcje do zczytywania danych z hardware'u,
 start, stop, (strumienia pomiarów)
 jak jest odczyt, wywołać funkcje, która podam
 */
class Magnetometer {
    private let motionManager = CMMotionManager()
    
    var frequency: Double {
        set {
            motionManager.deviceMotionUpdateInterval = newValue
        }
        get {
            return motionManager.deviceMotionUpdateInterval
        }
    }
    
    func start(handler: (motion: CMDeviceMotion?) -> Void) {
        print("start from magnetometer")
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XMagneticNorthZVertical, toQueue: NSOperationQueue.mainQueue()) {
            data, error in
            if let _ = error {
                print("error")
            } else {
                handler(motion: data)
            }
        }
    }
    
    func stop() {
        print("stop from magnetometer")
        motionManager.stopDeviceMotionUpdates()
    }
}
