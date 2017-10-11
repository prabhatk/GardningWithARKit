//
//  ViewController.swift
//  GardningWithARKit
//
//  Created by Prabhat Kasera on 10/6/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
//        addCube()
        addTexturedCube()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            // near future we will see the verticall also
            
            // Run the view's session
            sceneView.session.run(configuration)
            
        }
        else {
            print("ArWorldTrackingConfiguration is Not Supported.")
        }
    }
    func drawTreeAtPoint(vectorPoint : SCNVector3) {
        if let treeScene = SCNScene(named: "art.scnassets/Lowpoly_tree_sample.scn"){
            if let treeNode = treeScene.rootNode.childNode(withName: "Tree_lp_11", recursively: true){
                treeNode.position = vectorPoint
                sceneView.scene.rootNode.addChildNode(treeNode)
            }
        }
    }
    func addCube() {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        cube.materials = [material]
        
        let node = SCNNode(geometry: cube)
        node.position = SCNVector3Make(0.0, 0.0, 2.0)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func addTexturedCube() {
        let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/blueTexture.jpg")
        //Digital Asset Exchange File
        cube.materials = [material]
        
        let node = SCNNode(geometry: cube)
        node.position = SCNVector3Make(0.0, 0.0, 1.5)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func addTexturedCubeWithVectorPoint(vectorPoint : SCNVector3) {
        let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.02)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/blueTexture.jpg")
        //Digital Asset Exchange File
        cube.materials = [material]
        
        let node = SCNNode(geometry: cube)
        node.position = vectorPoint
        self.sceneView.scene.rootNode.addChildNode(node)
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
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1. We will check whether it is coming from horizental plane detection
        // ARPlaneAncor is the plane which is detected by the ARKit.
        if anchor is ARPlaneAnchor {
            print("plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3Make(planeAnchor.center.x, (0.01) / 2.0 , planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0) // to rotate plane in 90 degree at xaxis
            
            // adding grid material to the plane node
            let planeMaterial = SCNMaterial()
            planeMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [planeMaterial]
            
            //adding plane node geometry as plane
            planeNode.geometry = plane
            
            self.sceneView.scene.rootNode.addChildNode(planeNode)
            
        }
        else {
            print("unable to detect the plane")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !results.isEmpty {
            print("touched plane.")
            if let hitResult = results.first {
                let vectorPoint = SCNVector3Make(
                    hitResult.worldTransform.columns.3.x,
                    hitResult.worldTransform.columns.3.y,
                    hitResult.worldTransform.columns.3.z)
                drawTreeAtPoint(vectorPoint: vectorPoint)
            }
        }
        else {
            print("touched but not in plane.")
            if let hitResult = results.first {
                let vectorPoint = SCNVector3Make(
                    hitResult.worldTransform.columns.3.x,
                    hitResult.worldTransform.columns.3.y,
                    hitResult.worldTransform.columns.3.z)
                addTexturedCubeWithVectorPoint(vectorPoint: vectorPoint)
            }
        }
    }
    
}
