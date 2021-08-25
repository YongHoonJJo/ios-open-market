//
//  ImagePickerTableViewCell.swift
//  OpenMarket
//
//  Created by 잼킹 on 2021/08/25.
//

import UIKit

class ImagePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func addView() {
        let image = UIImageView()
        image.backgroundColor = .red
        image.adjustsImageSizeForAccessibilityContentSizeCategory = false
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        stackView.addArrangedSubview(image)
    }

}
