//
//  TopThreeCoinCell.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/24.
//

import UIKit

class TopCoinCell: UICollectionViewCell {
    
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinChangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        coinNameLabel.text = ""
        coinSymbolLabel.text = ""
        coinChangeLabel.text = ""
    }
    
    func setUpCell(with coin: Coin) {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(rgb: 0xF9F9F9)
        contentView.clipsToBounds = false
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowColor = UIColor(white: 000000, alpha: 0.1).cgColor
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        
        if let rawUrl = coin.iconUrl,
           let url = URL(string: rawUrl.replacingOccurrences(of: ".svg", with: ".png")) {
            coinIcon.setImage(url)
        }
        coinIcon.layer.masksToBounds = true
        
        coinNameLabel.text = coin.name ?? ""
        coinNameLabel.textColor = UIColor(rgb: 0x999999)
        coinNameLabel.font = UIFont.systemFont(ofSize: 12)
        coinNameLabel.textAlignment = .center
        coinNameLabel.numberOfLines = 1

        coinSymbolLabel.text = coin.symbol ?? ""
        coinSymbolLabel.textColor = UIColor(rgb: 0x3C3C3C)
        coinSymbolLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        coinSymbolLabel.textAlignment = .center
        
        let attachment = NSTextAttachment()
        let attrMub = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 12, weight: .bold)
        if let changeString = coin.change, let changeDouble = Double(changeString) {
            if changeDouble > 0 {
                let img = UIImage(systemName: "arrow.up")?.withTintColor(UIColor(rgb: 0x13BC24))
                attachment.image = img
                attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
                let attrImage = NSAttributedString(attachment: attachment)
                let attrStr = NSAttributedString(string: " " + (coin.change?.to2Decimal ?? ""), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x13BC24)])
                attrMub.append(attrImage)
                attrMub.append(attrStr)
            } else {
                let img = UIImage(systemName: "arrow.down")?.withTintColor(UIColor(rgb: 0xF82D2D))
                attachment.image = img
                attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
                let attrImage = NSAttributedString(attachment: attachment)
                attrMub.append(attrImage)
                let attrStr = NSAttributedString(string: " " + (coin.change?.to2Decimal ?? ""), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xF82D2D)])
                attrMub.append(attrStr)
            }
        }
        coinChangeLabel.attributedText = attrMub
    }
}
