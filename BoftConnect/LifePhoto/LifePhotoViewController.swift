import AVFoundation
import UIKit
import Vision
import DelaunaySwift

class LifePhotoViewController: UIViewController {
    private var session: AVCaptureSession?
    private var sequenceHandler = VNSequenceRequestHandler()
    @IBOutlet weak var imageV: UIImageView!

    
    private let faceDetection = VNDetectFaceRectanglesRequest()
    private let faceLandmarks = VNDetectFaceLandmarksRequest()
    private let faceLandmarksDetectionRequest = VNSequenceRequestHandler()
    private let faceDetectionRequest = VNSequenceRequestHandler()
    
    var previewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var faceView: FaceView!
    @IBOutlet weak var laserView: LaserView!
    @IBOutlet weak var faceLaserLabel: UILabel!

    private var faceViewHidden = false
    private var faceHidden = false

    private var maxX: CGFloat = 0.0
    private var midY: CGFloat = 0.0
    private var maxY: CGFloat = 0.0
    
    private var saveHigthNose: CGFloat!
    private var saveWidthNose: CGFloat!
    private var higthNose: CGFloat!
    private var widthNose: CGFloat!
    private var imagePO = #imageLiteral(resourceName: "nose03").resizeImage(image: #imageLiteral(resourceName: "nose03"), targetSize: CGSize(width: 200, height: 200))

    private var positionCamera = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        laserView.isHidden = true
        imageV.image = #imageLiteral(resourceName: "nose06")
        
        configureCaptureSession(position: .front)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        faceLaserLabel.isUserInteractionEnabled = true
        faceLaserLabel.addGestureRecognizer(tap)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(beck))


        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(cameraChange))
        
        
    }


    // MARK: - CameraPhoto
    @objc func cameraChange() {

        if positionCamera {
            configureCaptureSession(position: .back)
            positionCamera.toggle()
        } else {
            configureCaptureSession(position: .front)
            positionCamera.toggle()
        }
        print(positionCamera)
    }

    // MARK: - Beck to main menu
    @objc func beck() {
        self.dismiss(animated: true)
    }

    // MARK: - Gesture methods
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("Tap")
        faceView.isHidden.toggle()
        laserView.isHidden.toggle()
        
        faceViewHidden = faceView.isHidden

        if faceViewHidden {
            faceLaserLabel.text = "Mask"
        } else {
            faceLaserLabel.text = "Face"
        }
    }
 
}

//
//// MARK: - Video Processing methods
//
extension LifePhotoViewController {
    //Создание сесии с камерой
    func configureCaptureSession(position: AVCaptureDevice.Position) {
        session = AVCaptureSession()
        guard let session = session else {
             return
         }
        
        if session.inputs.count > 0 {
            for i in session.inputs {
                session.removeInput(i)
            }
        }
        
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
        for: AVMediaType.video, position: position) else {
                                                    fatalError("No front video camera available")
        }

        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.beginConfiguration()
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            }
            if session.outputs.count == 0 {
                // Create the video data output
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.videoSettings = [
                    String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                ]
                videoOutput.alwaysDiscardsLateVideoFrames = true
                
                let videoConnection = videoOutput.connection(with: .video)
                videoConnection?.videoOrientation = .portrait

                let queue = DispatchQueue(
                label: "video data queue",
                qos: .userInitiated,
                attributes: [],
                autoreleaseFrequency: .workItem)
                videoOutput.setSampleBufferDelegate(self, queue: queue)

                // Add the video output to the capture session
                if session.canAddOutput(videoOutput) {
                    session.addOutput(videoOutput)
                    let videoConnection = videoOutput.connection(with: .video)
                    videoConnection?.videoOrientation = .portrait
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = view.bounds
                    view.layer.insertSublayer(previewLayer, at: 0)
                    
                }
                
            }
            
            if session.outputs.count > 0 {
                for i in 1...session.outputs.count {
                    session.outputs[i-1].connection(with: .video)?.videoOrientation = .portrait
                }
            }
            session.commitConfiguration()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.maxX = view.bounds.maxX
        self.midY = view.bounds.midY
        self.maxY = view.bounds.maxY
        self.session?.startRunning()
        
        

        
        // Configure the preview layer


    }
}

//// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
//
extension LifePhotoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1 Получить буфер изображения из переданного в буфер образца
        guard let imageBuffer  = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                   return
        }
        

        
        guard let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault,
                                                              target: sampleBuffer,
                                                              attachmentMode: kCMAttachmentMode_ShouldPropagate)
            as? [CIImageOption: Any] else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer,
                              options: attachments)
        
//        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
        
        DispatchQueue.main.async {
            self.imageV.image = UIImage(ciImage: ciImage)
        }
 
        detectFace(on: ciImage)
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }

    }
    
    
}
//
extension LifePhotoViewController {
    
    fileprivate func detectFace(on image: CIImage) {
        try? faceDetectionRequest.perform([faceDetection], on: image)
        if let results = faceDetection.results as? [VNFaceObservation] {
            if !results.isEmpty {
                faceLandmarks.inputFaceObservations = results
                detectLandmarks(on: image)
            } else {
                faceView.clear()
            }
            guard let result = results.first else {
                return
            }
        
            if faceViewHidden {
                updateLaserView(for: result)
            } else {
                updateFaceView(for: result)
            }
        }
        
    }
    
    private func detectLandmarks(on image: CIImage) {
        try? faceLandmarksDetectionRequest.perform([faceLandmarks], on: image)
        guard let landmarksResults = faceLandmarks.results as? [VNFaceObservation] else {
            return
        }

        for observation in landmarksResults {
            if let boundingBox = faceLandmarks.inputFaceObservations?.first?.boundingBox {
                let faceBoundingBox = boundingBox.scaled(to: UIScreen.main.bounds.size)
//                print(faceBoundingBox)
                
//                var maparr = [Vertex]()

                    for (index, element) in convertPointsForFace(observation.landmarks?.allPoints, faceBoundingBox).enumerated() {
                                                                    
                    let point = CGPoint(x: (Double(UIScreen.main.bounds.size.width - element.point.x)),
                                        y: (Double(UIScreen.main.bounds.size.height - element.point.y)))
//                    maparr.append(Vertex(point: point, id: index))
                                                                    
//                    print(point)
                           
                        if index == 57 {
                            if self.saveHigthNose != nil {
                                self.widthNose = self.saveWidthNose - point.x
                            }
                        }
                        if index == 53 {
                            self.saveWidthNose = point.x
                        }
                        if index == 55 {
                            if self.saveHigthNose != nil {
                                self.higthNose = self.saveHigthNose - point.y
                            }
                        }
                        if index == 60 {
                            self.saveHigthNose = point.y
                        }
                        
                        if index == 57 {
                            DispatchQueue.main.async {
                                if self.widthNose != nil && self.higthNose != nil {
                                    let imageView = UIImageView(image: self.imagePO)
                                    imageView.frame = CGRect(origin: point, size: CGSize(width: self.widthNose, height: self.higthNose))
                                    self.faceHidden = true
                                    guard let viewWithTag = self.view.viewWithTag(225)  else {
                                        imageView.tag = 225
                                        self.view.addSubview(imageView)
                                        return
                                    }
                                    viewWithTag.removeFromSuperview()

                                    imageView.tag = 225
                                    self.view.addSubview(imageView)
                                }
                            }
                        }
                        
//                        DispatchQueue.main.async {
//                            let text = UITextField(frame: CGRect(origin: point, size: CGSize(width: 20, height: 10)))
//                            text.text = "\(index)"
//                            text.font = .systemFont(ofSize: 8)
//                            text.textColor = .white
//
//                            guard let viewWithTag = self.view.viewWithTag(index+425)  else {
//                                text.tag = index+425
//                                self.view.addSubview(text)
//                                return
//                            }
//                            viewWithTag.removeFromSuperview()
//
//                            text.tag = index+425
//                            self.view.addSubview(text)
//                        }
                                                                    
                                                                    
                }
            }
        }
        
        
    }
    
    private func convertPointsForFace(_ landmark: VNFaceLandmarkRegion2D?,
                                      _ boundingBox: CGRect) -> [Vertex] {
        guard let points = landmark?.normalizedPoints else {
            return []
        }
        let faceLandmarkPoints = points.map { (point: CGPoint) -> Vertex in
            let pointX = point.x * boundingBox.width + boundingBox.origin.x
            let pointY = point.y * boundingBox.height + boundingBox.origin.y

            return Vertex(point: CGPoint(x: Double(pointX), y: Double(pointY)), id: 0)
        }

        return faceLandmarkPoints
    }
    
    
    func convert(rect: CGRect) -> CGRect {
        // 1
        
        guard let previewLayer = previewLayer else {
            return CGRect()
        }
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)

        // 2
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

        // 3
        return CGRect(origin: origin, size: size.cgSize)
    }

    // 1
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)

        // 3
        let converted = previewLayer!.layerPointConverted(fromCaptureDevicePoint: absolute)

        // 4
        return converted
    }

    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }

        return points.compactMap { landmark(point: $0, to: rect) }
    }


    //
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }

        let box = result.boundingBox

        faceView.boundingBox = convert(rect: box)

        guard let landmarks = result.landmarks else {
            return
        }

        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEye = leftEye
        }

        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEye = rightEye
        }

        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEyebrow = leftEyebrow
        }

        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEyebrow = rightEyebrow
        }

        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            faceView.nose = nose
        }

        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.outerLips = outerLips
        }

        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.innerLips = innerLips
        }

        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            faceView.faceContour = faceContour
        }
    }

    // 1
    func updateLaserView(for result: VNFaceObservation) {
        // 2
        laserView.clear()

        // 3
        let yaw = result.yaw ?? 0.0

        // 4
        if yaw == 0.0 {
            return
        }

        // 5
        var origins: [CGPoint] = []

        // 6 leftPupil
        if let point = result.landmarks?.leftPupil?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 7 rightPupil
        if let point = result.landmarks?.rightPupil?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 8 faceContour
        if let point = result.landmarks?.faceContour?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 9 innerLips
        if let point = result.landmarks?.innerLips?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 10 leftEye
        if let point = result.landmarks?.leftEye?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        // 11 rightEye
        if let point = result.landmarks?.rightEye?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        // 12 leftEyebrow
        if let point = result.landmarks?.leftEyebrow?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        // 13 rightEyebrow
        if let point = result.landmarks?.rightEyebrow?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 14 medianLine
        if let point = result.landmarks?.medianLine?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        // 15 nose
        if let point = result.landmarks?.nose?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        // 16 noseCrest
        if let point = result.landmarks?.noseCrest?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }

        // 17 outerLips
        if let point = result.landmarks?.outerLips?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }




        // 1
        let avgY = origins.map { $0.y }.reduce(0.0, +) / CGFloat(origins.count)

        // 2
        let focusY = (avgY < midY) ? 0.75 * maxY : 0.25 * maxY

        // 3
        let focusX = (yaw.doubleValue < 0.0) ? -100.0 : maxX + 100.0

        // 4
        let focus = CGPoint(x: focusX, y: focusY)


        // 5
        for origin in origins {

            let laser = Laser(origin: origin, focus: focus)

            laserView.add(laser: laser)
        }

        // 6
        DispatchQueue.main.async {
            self.laserView.setNeedsDisplay()
        }
    }
//
//
    func detectedFace(request: VNRequest, error: Error?) {
        // 1 Извлеките первый результат из массива результатов наблюдения лица
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                // 2 Снимите флажок, FaceView если что-то идет не так, или лицо не обнаружено
                print("Нет лица")
                if faceHidden {
                    DispatchQueue.main.async {
                        guard let viewWithTag = self.view.viewWithTag(225)  else {
                            return
                        }
                        viewWithTag.removeFromSuperview()
                    }
                }
                
                faceView.clear()
                return
        }

        if faceViewHidden {
            updateLaserView(for: result)
        } else {
            updateFaceView(for: result)
        }
    }
}

extension CGRect {

    public func scaled(to size: CGSize) -> CGRect {
        return CGRect(x: self.origin.x * size.width,
                      y: self.origin.y * size.height,
                      width: self.size.width * size.width,
                      height: self.size.height * size.height)
    }

}
