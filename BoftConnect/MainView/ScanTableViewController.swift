import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class ScanTableViewController: UIViewController {
    var dismiss: Bool?
    
    @IBAction func beck(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
                guard let name = qrData?.codeString else {
                    return
                }
                self.parentView?.WIFISSID = name
            }
        }
    }
    
    var parentView: MainViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designFor(button: returnButton)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !scannerView.isRunning {
            scannerView.startScanning()
            if scannerView.fail {
                dismiss = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.dismiss == true {
            DispatchQueue.main.async {
                self.scannerView.isHidden = true
                self.presentAlert(withTitle: "Error", message: "Access to the camera is denied")
            }
        }
    }
    
        // MARK: - Сonnect WIFI
    private func connectWIFI(completioHandler : (() ->Void)?) {
        guard let WIFISSID = parentView?.WIFISSID else {
            return
        }
        let password = "7654asqw"
    
        let configuration = NEHotspotConfiguration.init(ssid: WIFISSID, passphrase: password, isWEP: false)
        configuration.joinOnce = false
        
        NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
            if error != nil {
                if error?.localizedDescription == "already associated."
                {
                    print("Connected already associated")
                    self.dismiss = true
                    completioHandler?()
                }
                else{
                    print("No Connected already associated")
                    self.dismiss = false
                    completioHandler?()
                }
            } else {
                print("Connected")
                self.parentView?.WIFISSID = WIFISSID
                self.dismiss = true
                completioHandler?()
            }

        }
    }
}

extension ScanTableViewController {
   private func showAlert (massage: String, title: String) {    // Вывод ошибки если пользователь ввел неправильно данные
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}

extension ScanTableViewController: QRScannerViewDelegate {
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
        self.connectWIFI {
            DispatchQueue.main.async {
                if self.dismiss == true {
                    self.parentView?.isOn = false
                    self.parentView?.customiseNavigationBar()
                    self.dismiss(animated: true)
                } else {
                    self.showAlert(massage: "Вам не удалось подключиться к сети", title: "Ошибка подключения")
                }
            }
        }
    }
}
