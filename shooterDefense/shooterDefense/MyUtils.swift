//
//  MyUtils.swift
//  shooterDefense
//
//  Created by Conner Hasbrouck on 9/24/16.
//  Copyright © 2016 Justin & Conner. All rights reserved.
//

import UIKit
import SpriteKit

func getScreenAspectRatioPortrait()->CGFloat{
    // bounds.width is in points (device independent), rather than pixels (device dependent)
    return UIScreen.main.bounds.width / UIScreen.main.bounds.height
}

func getScreenAspectRatioLandscape()->CGFloat{
    return UIScreen.main.bounds.height / UIScreen.main.bounds.width
}



func getPlayableRectPhonePortrait(size:CGSize)->CGRect{
    // Because we are using .aspectFill for our scenes, we don't need to worry about
    // physical screen sizes, we instead need to worry about screen aspect ratios.
    // (Which is much easier!)
    
    // We are designing for iPhone 5 and up aspect ratio == 9.0/16.0 == 0.5625 aspect ratio
    // ex. iPhone 5, 5s, SE resolution is 640 x 1136 == 9.0/16.0 == 0.5625 aspect ratio
    // ex. iPhone 6, 6s resolution is 750 x 1334 == 9.0/16.0 == 0.5625 aspect ratio
    // ex. iPhone 6 Plus, 6s Plus, 7 Plus resolution is 1080x1920 == 9.0/16.0 == 0.5625 aspect ratio
    // The scene will get scaled up or down depending on the resolution of the phone
    
    // If the device screen is an iPad, the aspect ratio ratio is 3.0/4.0, == 0.75 aspect ratio
    // ex. iPad, iPad 2, iPad Air, iPad Air 2 are 768 points x 1024 points == 0.75 aspect ratio
    // ex. iPad Pro (9.7 inch) is also 768 points x 1024 points == 0.75 aspect ratio
    // ex. iPad Pro (12.9 inch) is 1024 x 1366 == 0.75 aspect ratio
    
    // Here the *scene* aspect ration is always 0.5625
    let sceneAspectRatioPortrait = size.width/size.height
    // Get the aspect ratio of the *physical screen*
    let screenAspectRatio = getScreenAspectRatioPortrait()
    
    
    // if the aspect ratio of the device differs from the scene, calculate what will fit on the screen
    let playableHeight = size.height/(screenAspectRatio/sceneAspectRatioPortrait)
    
    // calculate how much we need to crop off the top and bottom
    let playableMargin = (size.height-playableHeight)/2.0
    // create the playable rect
    let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    
    return playableRect
}

func randomCGPointInRect(_ rect:CGRect,margin:CGFloat)->CGPoint{
    let x = CGFloat.random(min: rect.minX + margin, max: rect.maxX - margin)
    let y = CGFloat.random(min: rect.minY + margin, max: rect.maxY - margin)
    return CGPoint(x:x,y:y)
}

// JHAT: Make label creation much easier
func createPixeledLabel(pos: CGPoint, fontSize: CGFloat, text: String, name: String) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: "Pixeled")
    label.position = pos
    label.fontSize = fontSize
    label.text = text
    label.name = name
    label.fontColor = SKColor.white
    label.zPosition = 5
    return label
}

func createCustomLabel(fontString: String, pos: CGPoint, fontSize: CGFloat, text: String, name: String, color: SKColor) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: fontString)
    label.position = pos
    label.fontSize = fontSize
    label.text = text
    label.name = name
    label.zPosition = 5
    label.fontColor = color
    return label
}

func updateLabelProperties(labelToModify: SKLabelNode, pos: CGPoint, vAl: SKLabelVerticalAlignmentMode, hAl: SKLabelHorizontalAlignmentMode, text: String, fontSize: CGFloat, name: String) -> SKLabelNode {
    labelToModify.name = name
    labelToModify.position = pos
    labelToModify.verticalAlignmentMode = vAl
    labelToModify.horizontalAlignmentMode = hAl
    labelToModify.text = text
    labelToModify.fontSize = fontSize
    labelToModify.color = SKColor.white
    labelToModify.zPosition = 5
    if (labelToModify.fontName != "Pixeled") {
        labelToModify.fontName = "Pixeled"
    }
    return labelToModify
}


extension CGPoint{
    public static func randomUnitVector()->CGPoint{
        let vector = CGPoint(x:CGFloat.random(min:-1.0,max:1.0),y:CGFloat.random(min:-1.0,max:1.0))
        return vector.normalized()
    }
}

// used for debugging
func isIphone()->Bool{
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
}

func getDeviceModel()->String{
    return UIDevice.current.model
}

func getSystemNameAndVersion()->String{
    return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion) "
}

func getScreenRectInPoints()->CGRect{
    return UIScreen.main.bounds
}

func getScreenRectInPixels()->CGRect{
    // returns pixels
    return UIScreen.main.nativeBounds
}

func getScreenPhysicalScale()->CGFloat{
    // returns scale factor - higher value equals more pixels
    return UIScreen.main.nativeScale
}

func getScreenPhysicalAspectRatioPortrait()->CGFloat{
    return UIScreen.main.nativeBounds.width / UIScreen.main.nativeBounds.height
}
