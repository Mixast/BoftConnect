

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageFilter: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageFilter.translatesAutoresizingMaskIntoConstraints = false
        imageFilter.isUserInteractionEnabled = true
        
    }
    
}
