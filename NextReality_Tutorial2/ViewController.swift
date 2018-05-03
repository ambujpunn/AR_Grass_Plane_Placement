//
//  ViewController.swift
//  NextReality_Tutorial2
//
//  Created by Ambuj Punn on 5/2/18.
//  Copyright © 2018 Next Reality. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// 2.5
class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    // 2.2
    var grids = [Grid]()
    
    // 5.4
    var tappedTwice = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // 2.6
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        // 2.7
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // 4.1
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
        // 5.3
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        sceneView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // 2.5
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.delegate = self
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // 2.3
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 5.5
        if tappedTwice == false {
            let grid = Grid(anchor: anchor as! ARPlaneAnchor)
            self.grids.append(grid)
            node.addChildNode(grid)
        }
    }
    
    // 2.4
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 5.5
        if tappedTwice == false {
            let grid = self.grids.filter { grid in
                return grid.anchor.identifier == anchor.identifier
                }.first
            
            guard let foundGrid = grid else {
                return
            }
            
            foundGrid.update(anchor: anchor as! ARPlaneAnchor)
        }
    }
    
    // 4.2
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // 1.
        // Get exact position where touch happened on screen of iPhone (2D coordinate)
        let touchPosition = gesture.location(in: sceneView)
        
        // 2.
        
        // 5.1
        let hitTestResult = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            
            addGrass(hitTestResult: hitResult)
        }
    }
    
    // 4.3
    func addGrass(hitTestResult: ARHitTestResult) {
        // 1.
        let scene = SCNScene(named: "art.scnassets/grass.scn")!
        let grassNode = scene.rootNode.childNode(withName: "grass", recursively: true)
        grassNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        
        // 2.
        
        // 5.2.1
        // Identify which grid node to remove
        
        // Get identifier of hitTestResult's anchor
        let hitTestResultAnchorId = hitTestResult.anchor?.identifier
        let gridNode = self.grids.filter { (grid) -> Bool in
            return grid.anchor.identifier == hitTestResultAnchorId
        }.first
        
        // 5.2.2
        // If grid node found, replace grid with grass. Else, simply place grass on top of grid
        if let gridNodeFound = gridNode {
            // Remove grid from scene
            gridNodeFound.removeFromParentNode()
            
            // Remove grid from grid array
            self.grids = self.grids.filter {$0.anchor.identifier != gridNodeFound.anchor.identifier}
            
            // Remove gridNode anchor
            self.sceneView.session.remove(anchor: gridNodeFound.anchor)
            
            // Add grass node
            self.sceneView.scene.rootNode.addChildNode(grassNode!)
        }
        else {
            self.sceneView.scene.rootNode.addChildNode(grassNode!)
        }
    }
    
    // 5.6
    @objc func doubleTapped(gesture: UITapGestureRecognizer) {
        tappedTwice = !tappedTwice
    }
}
