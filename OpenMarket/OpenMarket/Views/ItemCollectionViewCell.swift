//
//  ItemCollectionViewCell.swift
//  OpenMarket
//
//  Created by YongHoon JJo on 2021/08/16.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemThumbnailImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDiscountedPriceLabel: UILabel!
    @IBOutlet weak var itemStockLabel: UILabel!

    func configure(with marketItem: MarketPageItem) {
        updateThumbnailImage(to: marketItem)
        updateLabels(to: marketItem)
    }
    
    private func updateLabels(to marketItem: MarketPageItem) {
        updateTitleLabels(to: marketItem)
        updatePriceLabels(to: marketItem)
        updateDiscountedPriceLabels(to: marketItem)
        updateStockLabels(to: marketItem)
//        itemTitleLabel.text = marketItem.title
//        itemPriceLabel.text = "\(marketItem.currency) \(marketItem.price)"
//        if let discountedPrice = marketItem.discountedPrice {
//            itemDiscountedPriceLabel.text = "\(marketItem.currency) \(discountedPrice)"
//        } else {
//            itemDiscountedPriceLabel.text = nil
//        }
//        itemStockLabel.text = marketItem.stock == .zero ? "품절" : "잔여수량 : \(marketItem.stock)"
    }
    
    private func updateTitleLabels(to marketItem: MarketPageItem) {
        itemTitleLabel.text = marketItem.title
    }
    
    private func getFormattedNumber(of number: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: number)) else {
            return nil
        }
        return formattedNumber
    }
    
    private func updatePriceLabels(to marketItem: MarketPageItem) {
        guard let text = itemPriceLabel.text,
              let price = getFormattedNumber(of: marketItem.price) else {
            return
        }
        
        if marketItem.discountedPrice != nil {
            let attributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: text)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            itemPriceLabel.attributedText = attributedString
            itemPriceLabel.textColor = .red
        } else {
            itemPriceLabel.attributedText = nil
            itemPriceLabel.textColor = .lightGray
        }
        itemPriceLabel.text = "\(marketItem.currency) \(price)"
    }
    
    private func updateDiscountedPriceLabels(to marketItem: MarketPageItem) {
        if let discountedPrice = marketItem.discountedPrice,
           let formattedDiscountedPrice = getFormattedNumber(of: discountedPrice) {
            itemDiscountedPriceLabel.text = "\(marketItem.currency) \(formattedDiscountedPrice)"
            itemDiscountedPriceLabel.textColor = .lightGray
        } else {
            itemDiscountedPriceLabel.text = nil
        }
    }
    
    private func updateStockLabels(to marketItem: MarketPageItem) {
        guard let stock = getFormattedNumber(of: marketItem.stock) else {
            return
        }
        
        if marketItem.stock == .zero {
            itemStockLabel.text = "품절"
            itemStockLabel.textColor = .orange
        } else {
            let enoughCount = 9999
            let leftover = marketItem.stock > enoughCount ? "충분함" : stock
            itemStockLabel.text = "잔여수량 : \(leftover)"
            itemStockLabel.textColor = .lightGray
        }
    }
    
    private func updateThumbnailImage(to marketItem: MarketPageItem) {
        for thumbnail in marketItem.thumbnails {
            if let url = URL(string: thumbnail),
                  let data = try? Data(contentsOf: url) {
                itemThumbnailImageView.image = UIImage(data: data)
                return
            }
        }
    }
}
