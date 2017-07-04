//
//  Plane.swift
//  MyARDemo
//
//  Created by Guanqi Yu on 22/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

import UIKit
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    var wolfNode: SCNNode!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        let grassImage = UIImage(named: "grass")
        self.planeGeometry = createPlane(size: CGSize(width: CGFloat(anchor.extent.x)
            , height: CGFloat(anchor.extent.z)), contents: grassImage!)
        super.init()
        self.geometry = planeGeometry
        self.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z)
        
        if wolfNode == nil {
            if let wolfScene = SCNScene(named: "art.scnassets/wolf/wolf.dae") {
                wolfNode = wolfScene.rootNode.childNode(withName: "wolf", recursively: true)
                wolfNode.transform = SCNMatrix4MakeRotation(Float.pi / 2.0, 1, 0, 0)
                self.addChildNode(wolfNode)
//                wolfNode.position = self.position
//                sceneView.scene.rootNode.addChildNode(wolfNode)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.geometry = planeGeometry
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
        
    }
}
