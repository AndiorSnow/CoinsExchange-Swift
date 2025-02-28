//
//  CoinDetailViewController.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/29.
//

import UIKit
import Combine

class CoinDetailViewController: UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var marketCapText: UILabel!
    @IBOutlet weak var coinMarketCapLabel: UILabel!
    @IBOutlet weak var coinDescriptionLabel: UILabel!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var coinWebsiteButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private let viewModel: CoinDetailViewModel = CoinDetailViewModel()
    private var bindings = Set<AnyCancellable>()
    var coinId: String?
    
    private var isloading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpBindings()
        if let coinId = coinId {
            viewModel.setUpDetail(coinId: coinId)
        }
    }
    
    func setUpViews() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeDetailedView))
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        backgroundView.addGestureRecognizer(closeGesture)
        backgroundView.isUserInteractionEnabled = true
        
        detailView.backgroundColor = .white
        detailView.clipsToBounds = false
        detailView.layer.cornerRadius = 10
        detailView.layer.masksToBounds = false
        
        if let rawUrl = viewModel.detailCoin?.iconUrl,
           let url = URL(string: rawUrl.replacingOccurrences(of: ".svg", with: ".png")) {
            coinIcon.setImage(url)
        }
        coinIcon.layer.masksToBounds = true
        
        func hexStringToInt(_ hex: String) -> Int {
            let scanner = Scanner(string: hex)
            var result: UInt64 = 0
            if scanner.scanHexInt64(&result) {
                return Int(result)
            } else {
                return 0x000000
            }
        }
        coinNameLabel.text = viewModel.detailCoin?.name ?? ""
        if let rawColor = viewModel.detailCoin?.color,
           let coinColor = UInt(rawColor.replacingOccurrences(of: "#", with: ""), radix: 16) {
            coinNameLabel.textColor = UIColor(rgb: coinColor)
        }
        coinNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        coinNameLabel.textAlignment = .left
        coinNameLabel.numberOfLines = 1
        coinNameLabel.lineBreakMode = .byTruncatingTail
        
        if let text = viewModel.detailCoin?.symbol {
            coinSymbolLabel.text = "(" + text + ")"
        } else {
            coinSymbolLabel.text = ""
        }
        coinSymbolLabel.textColor = .black
        coinSymbolLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        priceText.text = "PRICE"
        priceText.textColor = UIColor(rgb: 0x333333)
        priceText.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        coinPriceLabel.text = "$ " + (viewModel.detailCoin?.price?.to2Decimal ?? "")
        coinPriceLabel.textColor = UIColor(rgb: 0x333333)
        coinPriceLabel.font = UIFont.systemFont(ofSize: 12)
        
        marketCapText.text = "MARKET CAP"
        marketCapText.textColor = UIColor(rgb: 0x333333)
        marketCapText.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        coinMarketCapLabel.text = "$ " + (viewModel.detailCoin?.marketCap?.to2DecimalUnit ?? "")
        coinMarketCapLabel.textColor = UIColor(rgb: 0x333333)
        coinMarketCapLabel.font = UIFont.systemFont(ofSize: 12)
        
        coinDescriptionLabel.text = (viewModel.detailCoin?.description ?? "") + "\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n"
        coinDescriptionLabel.lineBreakMode = .byClipping
        coinDescriptionLabel.textColor = UIColor(rgb: 0x999999)
        coinDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        coinDescriptionLabel.numberOfLines = 0
        
        spacer.backgroundColor = UIColor(rgb: 0xEEEEEE)
        
        coinWebsiteButton.setTitle("GO TO WEBSITE", for: .normal)
        coinWebsiteButton.backgroundColor = .clear
        coinWebsiteButton.setTitleColor(UIColor(rgb: 0x38A0FF), for: .normal)
        coinWebsiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        coinWebsiteButton.addTarget(self, action: #selector(openCoinWeb), for: .touchUpInside)
        
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 1
        config.image = UIImage(named: "close")?.withTintColor(UIColor(rgb: 0x444444))
        closeButton.configuration = config
        closeButton.addTarget(self, action: #selector(closeDetailedView), for: .touchUpInside)
    }
    
    private func setUpBindings() {
        func bindViewModelToView() {
            viewModel.$detailCoin
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.setUpViews()
                })
                .store(in: &bindings)
        }
        bindViewModelToView()
    }
    
    @IBAction func closeDetailedView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func openCoinWeb(_ sender: Any) {
        guard let rawUrl = viewModel.detailCoin?.websiteUrl, let url = URL(string: rawUrl) else { return }
        UIApplication.shared.open(url)
    }
}
