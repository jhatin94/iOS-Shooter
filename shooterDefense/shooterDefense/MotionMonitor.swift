//
//  MotionMonitor.swift
//  shooterDefense
//
//  Created by Conner Hasbrouck on 9/24/16.
//  Copyright © 2016 Justin & Conner. All rights reserved.
//

import Foundation
import CoreMotion
import CoreGraphics

class MotionMonitor{
    
    static let sharedMotionMonitor = MotionMonitor() // #single isntance
    let manager = CMMotionManager() // get rotation magentometer, altitude
    var rotation:CGFloat = 0 // rotation in radians
    var gravityVectorNormalized = CGVector.zero // dx, dy values betweek -1 to +1
    var gravityVector = CGVector.zero // dx, dy values between -9.8 to +9.8
    var transform = CGAffineTransform(rotationAngle: 0) // a 3x3 Matrix
    
    
    //prevents default inti of class
    private init() {}
    
    func startUpdates(){
        if manager.isDeviceMotionAvailable {
            print("** starting motion updates **")
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdates(to: OperationQueue.main){ // trailing clsure syntex
                data, error in
                guard data != nil else { //guard. bail if no data
                    print ("There was an error: \(error)")
                    return
                }
                
                // self.rotation use - 2 * CGFloat.po for a landscape game
                self.rotation = CGFloat(atan2(data!.gravity.x, data!.gravity.y)) - CGFloat.pi
                
                //a unit vector
                self.gravityVectorNormalized = CGVector(dx:CGFloat(data!.gravity.x), dy:CGFloat(data!.gravity.y))
                
                //gravirty vector we will use in project 2 physics game
                self.gravityVector = CGVector(dx:CGFloat(data!.gravity.x), dy:CGFloat(data!.gravity.y))
                
                //affine transforms are commonly used on UIView instance
                self.transform = CGAffineTransform(rotationAngle: CGFloat(self.rotation))
                
                print("self.rotation = \(self.rotation)")
                print("self.gravityVectorNormalized = \(self.gravityVectorNormalized)")
                // print("self.gravityVector = \(self.gravityVector)")
                //print("self.transform = \(self.transform)")
            } // end block
        } else{
            print("Device Motion is not available! are you on a simulator?")
        }
    }
    
    func stopUpdates(){
        print("** stopping motion updates **")
        if manager.isDeviceMotionActive{
            manager.stopDeviceMotionUpdates()
        }
    }
}
