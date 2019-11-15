import UIKit
import ARKit

class MasterViewController: UIViewController {
    
    @IBOutlet var scenView: ARSCNView!
    
    let noseOptions = ["nose01", "nose02", "nose03", "nose04", "nose05", "nose06", "nose07", "nose08", "nose09"]
    let features = ["nose"]
    var featureIndices = [[6]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scenView.delegate = self
        scenView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        if (ARConfiguration.isSupported) {
            // ARKit is supported. You can work with ARKit
            if (ARFaceTrackingConfiguration.isSupported) {
                let configuration = ARFaceTrackingConfiguration()
                scenView.session.run(configuration)
            } else {
                let scene = SCNScene()
                scenView.scene = scene
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = [.vertical, .horizontal]
                configuration.isLightEstimationEnabled = true
                scenView.session.run(configuration)
                scenView.translatesAutoresizingMaskIntoConstraints = false
                scenView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                scenView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                scenView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                scenView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                scenView.session.run(configuration, options: [])
                scenView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

                print("2")
            }
        } else {
            // ARKit is not supported. You cannot work with ARKit

        }


    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        scenView.session.pause()
    }




    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        print("tap")
        let location = sender.location(in: scenView)
        let results = scenView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? FaceNode {
            node.next()
        }
    }



    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        print(featureIndices)
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
        }
    }
    
    
}

extension MasterViewController: ARSCNViewDelegate {
    
    func create(named: String, anchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        node.name = named
        node.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        node.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        node.geometry?.firstMaterial?.diffuse.contents = named == "Wall" ? #imageLiteral(resourceName: "icons8-synchronize-80") : #imageLiteral(resourceName: "icons8-broken-link-80")
        node.geometry?.firstMaterial?.isDoubleSided = true
        node.position = SCNVector3(CGFloat(anchor.extent.x), CGFloat(anchor.extent.y), CGFloat(anchor.extent.z))
        node.position = SCNVector3Make(anchor.extent.x, anchor.extent.y, anchor.extent.z)
       
        
        return node
    }
    
    func removeNode(named: String) {
        scenView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {
            return
        }
        print("Add plane anchor", anchorPlane.extent)
        var name = "Wall"
        if anchorPlane.alignment == ARPlaneAnchor.Alignment.vertical {
            name = "Wall"
        } else {
            name = "Floor"
        }
        let planeNode = create(named: name, anchor: anchorPlane)
        node.addChildNode(planeNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if (ARConfiguration.isSupported) {
            // ARKit is supported. You can work with ARKit
            if (ARFaceTrackingConfiguration.isSupported) {
                guard let faceAnchor = anchor as? ARFaceAnchor,
                    let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                        return
                }
                
                faceGeometry.update(from: faceAnchor.geometry)
                updateFeatures(for: node, using: faceAnchor)
            } else {
                guard let anchorPlane = anchor as? ARPlaneAnchor else {
                    return
                }
                print("Update plane anchor", anchorPlane.extent)
                
                var name = "Wall"
                if anchorPlane.alignment == ARPlaneAnchor.Alignment.vertical {
                    name = "Wall"
                } else {
                    name = "Floor"
                }
                removeNode(named: name)
                let planeNode = create(named: name, anchor: anchorPlane)
                node.addChildNode(planeNode)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {
            return
        }
        print("Remove plane anchor", anchorPlane.extent)
        var name = "Wall"
        if anchorPlane.alignment == ARPlaneAnchor.Alignment.vertical {
            name = "Wall"
        }
        else {
            name = "Floor"
        }
        removeNode(named: name)

    }

//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//
//        let device: MTLDevice!
//        device = MTLCreateSystemDefaultDevice()
//        guard let faceAnchor = anchor as? ARFaceAnchor else {
//            return nil
//        }
//        let faceGeometry = ARSCNFaceGeometry(device: device)
//        let node = SCNNode(geometry: faceGeometry)
//        node.geometry?.firstMaterial?.fillMode = .lines
//        node.geometry?.firstMaterial?.transparency = 0.0
//
//        let noseNode = FaceNode(with: noseOptions)
//        noseNode.name = "nose"
//        node.addChildNode(noseNode)
//
//        updateFeatures(for: node, using: faceAnchor)
//
//        return node
//    }
    
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
