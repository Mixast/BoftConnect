import UIKit
import ImageFilter
import CoreImage

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let filter = Filter()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var filterList: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var intensity: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var scaleKeySlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
    
    var imageCellArray = [Data]()
    
    var currentImage: UIImage?
    var currentFilter: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photo editor"
        
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(ImportPicture))
        rightBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationItem.rightBarButtonItem!.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(beck))

        designFor(button: filterList)
        designFor(button: buttonSave)
        intensity.isHidden = true
        radiusSlider.isHidden = true
        scaleKeySlider.isHidden = true
        angleSlider.isHidden = true
        
        filterList.isHidden = true
        buttonSave.isHidden = true
        collectionView.isHidden = true

        imageView.frame = CGRect(x: 0 , y: 0, width: imageView.frame.width, height: imageView.frame.width * 0.2)

    }
    
    // MARK: - Beck to main menu
    @objc func beck() {
        self.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIImagePickerController
    
    @objc func ImportPicture() {
        let image  = UIImagePickerController()
        image.allowsEditing = true
        image.delegate = self
        present(image, animated: true)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        dismiss(animated: true)
        currentImage = image
        imageView.image = filter.addFilter(inputImage: image, currentFilter: nil, inputIntensity: nil, inputRadius: nil, inputScale: nil, inputAngle: nil)
        filterList.isHidden = false
        buttonSave.isHidden = true

        DispatchQueue.main.async {
            self.imageCellArray.removeAll()
            for _ in 1...filterDeck.count {
                let data = Data()
                self.imageCellArray.append(data)
            }
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }

    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        if filterDeck.count != 0 {
            for i in 1...filterDeck.count {
                ac.addAction(UIAlertAction(title: filterDeck[i-1], style: .default, handler: setFilter))
            }
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverContriler = ac.popoverPresentationController {
            popoverContriler.sourceView = sender
            popoverContriler.sourceRect = sender.bounds
        }

        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        print("Popa")
        
    }
    
    // MARK: - Cliders
    
    @IBAction func intensityAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.imageView.image = self.filter.addFilter(inputImage: .none, currentFilter: .none, inputIntensity: self.intensity.value, inputRadius: 1, inputScale: 1, inputAngle: 1)
        }
    }
    

    @IBAction func radiusCliderAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.imageView.image = self.filter.addFilter(inputImage: .none, currentFilter: .none, inputIntensity: 1, inputRadius: self.radiusSlider.value, inputScale: 1, inputAngle: 1)
        }
    }
    
    
    @IBAction func scaleKeySliderAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.imageView.image = self.filter.addFilter(inputImage: .none, currentFilter: .none, inputIntensity: 1, inputRadius: 1, inputScale: self.scaleKeySlider.value, inputAngle: 1)
        }
    }
    
    @IBAction func angleSliderAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.imageView.image = self.filter.addFilter(inputImage: .none, currentFilter: .none, inputIntensity: 1, inputRadius: 1, inputScale: 1, inputAngle: self.angleSlider.value)
        }
    }
    // MARK: - Save
    @IBAction func save(_ sender: Any) {
        let ac = UIAlertController(title: "Save image?", message: "Вы хотете сохранить новую картинку?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.currentImage = self.imageView.image
            guard let image = self.currentImage else {
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            self.dismiss(animated: true)
            
        }))
        ac.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            self.imageView.image = self.currentImage
            
        }))
        present(ac, animated: true)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError eroor: Error?, contextInfo: UnsafeRawPointer) {
        if let error = eroor {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "You saved new image", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
            
        }
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterDeck.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 1 {
            return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height/1.5)
        } else {
            return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height/8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
            cell.label.text = ""
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
            cell.imageFilter.addGestureRecognizer(tapGestureRecognizer)
            tapGestureRecognizer.view?.tag = indexPath.section
            
            if indexPath.row < imageCellArray.count {
                if imageCellArray[indexPath.section] == Data() {
                    DispatchQueue.main.async {
                        self.requestImage(forIndex: indexPath)
                    }
                } else {
                    cell.imageFilter.image = UIImage(data: imageCellArray[indexPath.section])
                }
            }
            return cell
        } else if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell

            cell.imageFilter.image = UIImage()
            
            let text = filterDeck[indexPath.section]
            let start = text.index(text.startIndex, offsetBy: 2)
            let label = String(text[start..<text.endIndex])
            
            cell.label.text = label
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
            return cell
        }
        
    }
    
    
    
    func requestImage(forIndex: IndexPath) {
        if imageCellArray.count > 0 {
            if imageCellArray[forIndex.section] == Data() {
                let imageCell = self.filter.addFilter(inputImage: .none, currentFilter: Filter.CurrentFilter(rawValue: filterDeck[forIndex.section]), inputIntensity: 1, inputRadius: 1, inputScale: 1, inputAngle: 1)
                
                guard let data = imageCell.pngData() else {
                    return
                }
                imageCellArray[forIndex.section] = data
                collectionView.reloadItems(at: [forIndex])
            }
            
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let index = tapGestureRecognizer.view?.tag else {
            return
        }
        if index < imageCellArray.count {
            imageView.image = UIImage(data: imageCellArray[index])
            
            
            let filter = CIFilter(name: Filter.CurrentFilter(rawValue: filterDeck[index])!.rawValue)
        
            guard let inputKeys = filter?.inputKeys else {
                return
            }
            
            if (inputKeys.contains(kCIInputIntensityKey)) {
                self.intensity.isHidden = false
                print("kCIInputIntensityKey")
            } else {
                self.intensity.isHidden = true
            }
            
            if (inputKeys.contains(kCIInputRadiusKey)) {
                self.radiusSlider.isHidden = false
                print("kCIInputRadiusKey")
            } else {
                self.radiusSlider.isHidden = true
            }
            
            if (inputKeys.contains(kCIInputScaleKey)) {
                self.scaleKeySlider.isHidden = false
                print("kCIInputScaleKey")
            } else {
                self.scaleKeySlider.isHidden = true
            }
            
            if (inputKeys.contains(kCIInputCenterKey)) {
                
                print("kCIInputCenterKey")
            } else {
                
            }
            
            if (inputKeys.contains(kCIInputMaskImageKey)) {
                self.radiusSlider.isHidden = false
                print("kCIInputMaskImageKey")
            
            } else {
            }
            
            if (inputKeys.contains(kCIInputAngleKey)) {
                self.angleSlider.isHidden = false
                print("kCIInputAngleKey")
            } else {
            }
            
            
            if (inputKeys.contains(kCIInputAmountKey)) {
                print("kCIInputAmountKey")
                self.angleSlider.isHidden = false
                
            } else {
                
            }
        }
        buttonSave.isHidden = false
    }

}
