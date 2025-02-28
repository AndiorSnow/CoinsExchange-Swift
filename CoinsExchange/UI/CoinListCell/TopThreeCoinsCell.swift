//
//  TopThreeCoinsCell.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import UIKit
import Combine

class TopThreeCoinsCell: UITableViewCell {
    
    @IBOutlet weak var topThreeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var callClickItem: ((String) -> Void)?
    
    @Published private var topCoins: [Coin] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        let str = NSMutableAttributedString(string: "Top 3 rank crypto")
        str.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: 4))
        str.addAttribute(.foregroundColor, value: UIColor.init(rgb: 0x333333), range: NSRange(location: 0, length: 4))
        str.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: NSRange(location: 4, length: 1))
        str.addAttribute(.foregroundColor, value: UIColor.init(rgb: 0xC52222), range: NSRange(location: 4, length: 1))
        str.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .medium), range: NSRange(location: 5, length: 12))
        str.addAttribute(.foregroundColor, value: UIColor.init(rgb: 0x333333), range: NSRange(location: 5, length: 12))
        topThreeLabel.attributedText = str
        
        let layout = UICollectionViewFlowLayout()
        let itemWidth = 110.0
        let itemHeight = 140.0
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.scrollDirection = .horizontal

        collectionView.collectionViewLayout = layout
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        contentView.isUserInteractionEnabled = true
        
        self.separatorInset = UIEdgeInsets(top: 0, left: itemWidth/2, bottom: 0, right: itemWidth/2)
    }
    
    func setUpCell(with coins: [Coin]) {
        self.topCoins = coins
        collectionView.reloadData()
    }
    
    
}

extension TopThreeCoinsCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TOP_THREE
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TopCoinCell? = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseId.collectionCell_id, for: indexPath) as? TopCoinCell
//        print (topCoins)
        if (topCoins.count > 0) {
            cell?.setUpCell(with: topCoins[indexPath.row])
        }
        return cell!
    }
}

extension TopThreeCoinsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIndex = indexPath.item
        let coin = topCoins[cellIndex]
        callClickItem?(coin.uuid)
//        viewModel.setUpDetail(coinId: coin.uuid)
//        print (coin)
//        getCoinDetail(coin: coin)
    }
}
