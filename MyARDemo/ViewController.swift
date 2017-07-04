//
//  ViewController.swift
//  MyARDemo
//
//  Created by Guanqi Yu on 21/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var drawLineButton: UIButton!
    
    var previousPoint: SCNVector3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureRecognize:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        guard  let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let imagePlane =  SCNPlane(width: sceneView.bounds.width / 6000,
                                   height: sceneView.bounds.height / 6000)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
     */
    
    // MARK: - Planes
    
    var planes = [ARPlaneAnchor: Plane]()
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor: anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
        
//        let wolfNode:SCNNode!
//        if let wolfScene = SCNScene(named: "art.scnassets/wolf/wolf.dae") {
//            wolfNode = wolfScene.rootNode.childNode(withName: "wolf", recursively: true)
//            wolfNode.position = plane.position
//            node.addChildNode(wolfNode)
//        }
        
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor: anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
            plane.wolfNode.removeFromParentNode()
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        addPlane(node: node, anchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        updatePlane(anchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        removePlane(anchor: planeAnchor)
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let pointOfView = sceneView.pointOfView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let mat = SCNMatrix4FromMat4(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
//        let currentPosition = getCameraCoordinate(sceneView: sceneView)
        
        if drawLineButton!.isHighlighted {
            if let previousPoint = previousPoint {
                let lineGeometry = lineFrom(vector: previousPoint, toVector: currentPosition)
                lineGeometry.firstMaterial?.diffuse.contents = UIColor.white
                let lineNode = SCNNode(geometry: lineGeometry)
                sceneView.scene.rootNode.addChildNode(lineNode)
            }
        }
        previousPoint = currentPosition
        glLineWidth(500)
    }
    
    func getCameraCoordinate(sceneView: ARSCNView) -> SCNVector3 {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        return SCNVector3(x: cameraCoordinates.translation.x, y: cameraCoordinates.translation.y, z: cameraCoordinates.translation.z)
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indicies: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indicies, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
