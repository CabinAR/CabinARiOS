//
//  ViewController.swift
//  CabinAR
//
//  Created by Pascal Rettig on 2/26/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit

import Kingfisher
import Starscream


class SpaceViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SCNSceneRendererDelegate, WKUIDelegate, WebSocketDelegate, WKNavigationDelegate {


    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var webView: WKWebView!
    var socket: WebSocket!
    
    var space: CabinSpace?
    var pieces: Dictionary<Int,CabinPiece> = [:]
    
    var activePieces:Dictionary<String,SCNNode> = [:]
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    func loadSpace() {
        CabinARApi.api.getSpace(self.space!.id) { space in
            self.space = space
            self.pieces = space!.pieces
            // set up the image bundle etcs
            
            let urls = self.pieces.map { URL(string: $1.marker_url!)! }
            
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("These resources are prefetched: \(completedResources)")
                self.resetTracking()

            }
            prefetcher.start()
            
            self.socket = CabinARApi.api.connectSocket(self)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        //sceneView.session.delegate = self

        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        self.edgesForExtendedLayout = []


        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self

        
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear

        self.webView.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.webView.frame.origin.x = 0
        self.webView.frame.origin.y = 0
        self.view.addSubview(self.webView)
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebAssets")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        
        self.view.bringSubviewToFront(webView)
        self.view.bringSubviewToFront(self.refreshButton)
        self.view.bringSubviewToFront(self.backButton)
                
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         loadSpace()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.socket?.disconnect()
    }
    // MARK: - ARSCNViewDelegate
    
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func websocketDidConnect(socket: WebSocketClient) {
        print("SOCKET:Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("SOCKET: Disconnected \(String(describing: error))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("SOCKET: message: \(text)")
        // Parse the message (api?)
        // if it's welcome, subscribe to SpaceUpdates w/ space_id
        
        let message = SocketMessage.create(text)
        
        if(message.type == "welcome") {
            let cmd = SocketCommand(command: "subscribe", space_id: self.space!.id)
            self.socket.write(string: cmd.toString())
        } else if(message.type == "subscribed") {
            print("SUBSCRIBED TO UPDATES")
        } else if(message.type == "piece") {
            let piece = CabinPiece.createSingle(json: message.data!)
            pieces[piece.id] = piece
            addPieceToWebview(piece)
        }
        

    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("data")
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func refreshView(_ sender: Any) {
        self.resetTracking()
    }
    
    
    func resetTracking() {
        
        let group = DispatchGroup()
        
        self.activePieces = [:]
        
        var pieceList:[(CabinPiece,Image)] = []

        for (_, piece) in self.space!.pieces {
            group.enter()
            KingfisherManager.shared.retrieveImage(with: URL(string: piece.marker_url!)!) { result in
                switch result {
                case .success(let value):
                    // The image was set to image view:
                    pieceList.append((piece, value.image))
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            var referenceImages:Set<ARReferenceImage> = []
            
            for pieceImage in pieceList {
                let referenceImage = ARReferenceImage(
                    pieceImage.1.cgImage!,
                    orientation: .up,
                    physicalWidth: CGFloat(pieceImage.0.marker_meter_width!) )
                referenceImage.name = String(pieceImage.0.id)
                referenceImages.insert(referenceImage)
            }
            
            self.addPiecesToWebview()
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = referenceImages
            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        }
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
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            
            self.activePieces[referenceImage.name!] = node
            
            let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.4)
            let boxNode = SCNNode(geometry: box)
            
            //let cameraTransform = camera?.transform
            //boxNode.simdTransform = cameraTransform!
            boxNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: 0))
            
            //planeNode.addChildNode(boxNode)
        }
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        
        var pieceTransforms:Dictionary<String,SCNMatrix4> = [:]
        
        for (name,node) in self.activePieces {
             pieceTransforms[name] = node.transform
        }

        updateWebViewCamera(pieceTransforms, camera:transform, projection: pointOfView.camera!.projectionTransform)
    }
    
    func printMatrix(_ matrix: SCNMatrix4) -> String {
        return String(format:"[%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f]",
                     matrix.m11, matrix.m21, matrix.m31, matrix.m41,
                     matrix.m12, matrix.m22, matrix.m32, matrix.m42,
                     matrix.m13, matrix.m23, matrix.m33, matrix.m43,
                     matrix.m14, matrix.m24, matrix.m34, matrix.m44)
    }
    
    func pieceString(_ piece:CabinPiece) -> String  {
        return  "setPieceEntity(\(piece.id), \(piece.marker_meter_width ?? 1.0), `\(piece.scene)`);"
    }
    
    func addPieceToWebview(_ piece:CabinPiece) {
        DispatchQueue.main.async {
            print(self.pieceString(piece))
            self.webView.evaluateJavaScript(self.pieceString(piece))
        }
    }
    
    
    func addPiecesToWebview() {
        DispatchQueue.main.async {
            var allStr = "";
            for (_,piece) in self.pieces  {
                allStr = allStr + self.pieceString(piece)
            }
            print(allStr)
            self.webView.evaluateJavaScript(allStr);
        }
    }
    
    
    
    func updateWebViewCamera(_ objects: Dictionary<String,SCNMatrix4>, camera: SCNMatrix4, projection: SCNMatrix4) {
        DispatchQueue.main.async {
            var objectTransforms = "{"
            for (key,transform) in objects {
                objectTransforms += "\n\(key): \(self.printMatrix(transform)),"
            }
            objectTransforms += "\n}";
            let cameraTransform = self.printMatrix(camera)
            let projectionTransform = self.printMatrix(projection)
            let str = "setScenePostParams(\(objectTransforms),\(cameraTransform),\(projectionTransform))"
            if(objects.count > 0) {
               print(str)
            }
            self.webView.evaluateJavaScript(str);
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25)
            ])
    }
}
