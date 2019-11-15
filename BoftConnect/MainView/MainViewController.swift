import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreBluetooth
import NetworkExtension
import WebKit
import Foundation



class MainViewController: UIViewController, UITextFieldDelegate {
    var networkList: [NEHotspotNetwork]?
    let width = 60
    let height = 60
    
    let inetReachability = InternetReachability()!
    var isOn = true

    var WIFISSID = "@BOFT__"
    var url = "boft.me"

    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var wifiInfo: UITextField!
    @IBOutlet weak var urlBoft: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = " Boft "
        
        let buttonCamera = UIButton(type: .custom)
        let imageCamera = #imageLiteral(resourceName: "icons8-polaroid-80")
        
        buttonCamera.setImage(imageCamera.resizeImage(image: imageCamera, targetSize: CGSize(width: width, height: height)), for: .normal)
        buttonCamera.addTarget(self, action: #selector(addCameraPhoto), for: .touchUpInside)
        buttonCamera.frame = CGRect(x: 0, y: 0, width: width+10, height: height+10)
        let camera = UIBarButtonItem(customView: buttonCamera)
        
        let buttonPhotoLibrary = UIButton(type: .custom)
        let imagePhotoLibrary = #imageLiteral(resourceName: "icons8-photo-gallery-80")
        
        buttonPhotoLibrary.setImage(imagePhotoLibrary.resizeImage(image: imagePhotoLibrary, targetSize: CGSize(width: width, height: height)), for: .normal)
        buttonPhotoLibrary.addTarget(self, action: #selector(addPhotoLibrary), for: .touchUpInside)
        buttonPhotoLibrary.frame = CGRect(x: 0, y: 0, width: width+10, height: height+10)
        let photoLibrary = UIBarButtonItem(customView: buttonPhotoLibrary)
        
        
        navigationItem.leftBarButtonItems = [camera, photoLibrary]
        
        inetReachability.whenReachable = { _ in
            DispatchQueue.main.async {
                print("Internet is OK!")
                self.text.text = "Internet is OK!"
            }
        }
        inetReachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                print("Internet connection FAILED!")
                self.text.text = "Internet connection FAILED!"
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: inetReachability)
        
        do {
            try inetReachability.startNotifier()
        } catch {
            print("Could not start notifier")
        }
        
        customiseNavigationBar()
        
        self.wifiInfo.delegate = self
        self.urlBoft.delegate = self
        wifiInfo.text = "@BOFT__"
        urlBoft.text = "boft.me"
    }
    
    // MARK: - CameraPhoto
    @objc func addCameraPhoto() {
        self.performSegue(withIdentifier: "goToCamera", sender: nil)
        print("addCameraPhoto")
    }
    // MARK: - PhotoLibrary
    @objc func addPhotoLibrary() {
        self.performSegue(withIdentifier: "goToPhotoLibrary", sender: nil)
        print("goToPhotoLibrary")
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var chek: Bool?
        
        if wifiInfo.text != WIFISSID {
            chek = true
        } else if urlBoft.text != url {
            chek = false
        }
        
        if wifiInfo.text == "" {
            WIFISSID = "@BOFT__"
        } else  {
            guard let text = wifiInfo.text else {
                return true
            }
            WIFISSID = text
        }
        
        if urlBoft.text == "" {
            url = "boft.me"
        } else  {
            guard let text = urlBoft.text else {
                return true
            }
            url = text
        }
        textField.resignFirstResponder()
        
        if chek == false {
            showAlert(massage: "Create new url", title: "Url: \(url)")
        } else if chek == true {
            showAlert(massage: "Create new WiFi name", title: "WiFi name: \(WIFISSID)")
        }

        return true
    }
    
// MARK: - WKWebView
    func createWKWebView(url: String ) {
        let positionY = self.view.frame.height / 3
        let myWebView: WKWebView = WKWebView(frame: CGRect(x: 0.0, y: positionY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        myWebView.tag = 100
        myWebView.isUserInteractionEnabled = true
        guard let url = URL(string: url) else {
            return
        }
        myWebView.load(URLRequest(url: url))

        self.view.addSubview(myWebView)
    }
    
    func disableWKWebView() {
        if let viewWithTag = self.view.viewWithTag(100) {
            print("Disable WKWebView")
            viewWithTag.removeFromSuperview()
        }
    }
    
// MARK: - NavigationBar
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        
        var rightButton = UIButton()
        
        if isOn {
            let buttonConnect = UIButton(type: .custom)
            let image = #imageLiteral(resourceName: "icons8-synchronize-80")
            buttonConnect.setImage(image.resizeImage(image: image, targetSize: CGSize(width: width, height: height)), for: .normal)
            buttonConnect.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
            buttonConnect.frame = CGRect(x: 0, y: 0, width: width+10, height: height+10)
            rightButton = buttonConnect
            
//            rightButton.setTitle("Connect", for: [])
//            rightButton.setTitleColor(UIColor.blue, for: [])
//            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
//            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
            
        } else {
            let buttonDisconnect = UIButton(type: .custom)
            let image = #imageLiteral(resourceName: "icons8-broken-link-80")
            buttonDisconnect.setImage(image.resizeImage(image: image, targetSize: CGSize(width: width, height: height)), for: .normal)
            buttonDisconnect.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
            buttonDisconnect.frame = CGRect(x: 0, y: 0, width: width+10, height: height+10)
            rightButton = buttonDisconnect
            
//            rightButton.setTitle("Disconnect", for: [])
//            rightButton.setTitleColor(UIColor.blue, for: [])
//            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
//            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    
        if self.isOn == false {
            print("Create")
            self.url = "http://172.16.172.47"
//            self.url = "https://www.youtube.com/watch?v=d33n5lJpP_I"
            self.createWKWebView(url: self.url)
        } else {
            self.disableWKWebView()
        }

    }

    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        print("reload")
        
        
    }
    
// MARK: - Button Methods
    @objc func scanButtonPressed() {
        self.performSegue(withIdentifier: "goToStart", sender: nil)
    }
    
    @objc func disconnectButtonPressed() {
        disableWKWebView()
        DisconnectWIFI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToStart") {

            let scanController: ScanTableViewController = segue.destination as! ScanTableViewController

            scanController.parentView = self
        }
        
    }
    
// MARK: - Internet Changed
    @objc func internetChanged(note:Notification) {
        let reachability =  note.object as! InternetReachability
        if reachability.connection != .none {
            if reachability.connection == .wifi {
                DispatchQueue.main.async {
                    print("Internet via WIFI is OK!")
                }
                
            } else {
                DispatchQueue.main.async {
                    print("Internet via Cellular is OK!")
                }
            }
            DispatchQueue.main.async {
                if self.isOn == false {
                    print("create")
                    self.createWKWebView(url: self.url)
                }
            }
        } else {
            print("No Internet connection! /n Please, check your internet connection")
            
        }
    }
    
    private func DisconnectWIFI() {
        print(WIFISSID)
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: WIFISSID)
        isOn = true
        customiseNavigationBar()
    }
}

extension MainViewController {
    //MARK: - Show Alert
    private func showAlert (massage: String, title: String) {    // Вывод ошибки если пользователь ввел неправильно данные
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

fileprivate extension NEHotspotHelper {
    static func managedSupportedNetworkInterfaces() -> [Any]? {
        var result: [Any]!
        if let unmanaged = NEHotspotHelper.perform(#selector(NEHotspotHelper.supportedNetworkInterfaces)) {
            result = unmanaged.takeUnretainedValue() as? [Any]
        }
        
        return result
    }
}


