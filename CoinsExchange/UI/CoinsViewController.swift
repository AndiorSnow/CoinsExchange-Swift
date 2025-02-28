//
//  ViewController.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import UIKit
import Combine

class CoinsViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var placer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var headerView = UIView(frame: .zero)
    private lazy var loadView = UIView(frame: .zero)
    private lazy var searchErrorView = UIView(frame: .zero)
    private lazy var loadErrorView = UIView(frame: .zero)
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    private let viewModel: CoinsViewModel = CoinsViewModel()
    private var bindings = Set<AnyCancellable>()
    
    private var coinsIndex: [Int] = []
    private var coinsIndexStart = TOP_THREE
    private var coinsIndexDifference = 0
    private var coinsInterval = 5
    private var searchCoinsIndex: [Int] = []
    private var searchCoinsIndexStart = 0
    private var searchCoinsIndexDifference = 0
    private var searchCoinsInterval = 5
    
    private var isLoading = true
    private var isSearching = false
    private var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpBindings()
        viewModel.setUpCoins()
        setUpCoinIndex()
    }
    
    func setUpViews() {
        view.backgroundColor = .white
        searchErrorView.isHidden = true
        loadErrorView.isHidden = true
        
        let placeholderText = NSMutableAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x9E9E9E)])
        searchBar.attributedPlaceholder = placeholderText
        searchBar.backgroundColor = UIColor(rgb: 0xEEEEEE)
        searchBar.borderStyle = .none
        searchBar.autocorrectionType = .no
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.layer.cornerRadius = 8
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 1))
        searchBar.leftView = leftView
        searchBar.leftViewMode = .always
        
        searchIcon.image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        searchIcon.tintColor = UIColor(rgb: 0xC4C4C4)
        searchIcon.contentMode = .scaleAspectFit
        
        clearButton.isHidden = true
        clearButton.setTitle("", for: .normal)
        clearButton.setImage(UIImage(named: "searchClose"), for: .normal)
        clearButton.imageView?.tintColor = UIColor(rgb: 0xC4C4C4)
        clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        
        placer.backgroundColor = UIColor(rgb: 0xEEEEEE)
        
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 0.01
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.estimatedSectionHeaderHeight = 0.01
        tableView.estimatedSectionFooterHeight = 0.01
        tableView.tableHeaderView = self.headerView
        
    }
    
    private func setUpBindings() {
        func bindViewToViewModel() {
            searchBar.textPublisher
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { [weak viewModel] in
                    if (self.searchErrorView.isHidden == false) {
                        self.searchErrorView.isHidden = true
                        self.tableView.isHidden = false
                    }
                    self.searchCoinsIndex.removeAll()
                    self.searchCoinsIndexStart = 0
                    self.searchCoinsIndexDifference = 0
                    self.searchCoinsInterval = 5
                    viewModel?.searchCoins(query: $0)
                    self.setUpSearchCoinIndex()
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.$coins
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.tableView.reloadData()
                })
                .store(in: &bindings)
            
            viewModel.$searchCoins
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.tableView.reloadData()
                })
                .store(in: &bindings)
            
            let stateValueHandler: (CoinsViewModelState) -> Void = { [weak self] state in
                switch state {
                case .loading:
                    self?.startLoading()
                case .finishedLoading:
                    self?.finishLoading()
                case .loadError:
                    self?.showloadError()
                case .searchError:
                    self?.showSearchError()
                }
            }
            
            viewModel.$state
                .receive(on: RunLoop.main)
                .sink(receiveValue: stateValueHandler)
                .store(in: &bindings)
        }
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    func startLoading() {
        isLoading = true
        loadErrorView.isHidden = true
        setUpInfiniteScrollingView()
        tableView.isUserInteractionEnabled = false
    }
    
    func finishLoading() {
        isLoading = false
        tableView.isUserInteractionEnabled = true
        tableView.reloadData()
    }

    func showloadError() {
        setUpLoadErrorView()
    }
    
    @objc func retryLoading() {
        isLoading = true
        loadErrorView.isHidden = true
        setUpInfiniteScrollingView()
        tableView.isUserInteractionEnabled = false
        if (isSearching == false) {
            viewModel.retrySetUpCoins()
        } else {
            viewModel.retrySearchCoins()
        }
    }
    
    func showSearchError() {
        tableView.isHidden = true
        setUpSearchErrorView()
    }
    
    func getCoinDetail(coinId: String) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: CellReuseId.coinDetailViewController_id) as? CoinDetailViewController else { return }
        viewController.coinId = coinId
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: nil)
    }
    
    func openInviteView() {
        guard let url = NSURL(string: "https://developers.coinranking.com/api") else { return }
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func setUpInfiniteScrollingView() {
        loadView.isHidden = false
        loadView = UIView(frame: CGRect(x: 0, y: tableView.contentSize.height,
                                                 width: tableView.bounds.size.width, height: 56))
        loadView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        loadView.backgroundColor = .white
        tableView.tableFooterView = self.loadView
        
        let activityViewIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityViewIndicator.color = UIColor.darkGray
        activityViewIndicator.startAnimating()
        loadView.addSubview(activityViewIndicator)
        
        activityViewIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityViewIndicator.centerXAnchor.constraint(equalTo: loadView.centerXAnchor),
            activityViewIndicator.centerYAnchor.constraint(equalTo: loadView.centerYAnchor)
        ])
        tableView.tableFooterView = self.loadView
    }
    
    private func setUpLoadErrorView() {
        loadView.isHidden = true
        loadErrorView.isHidden = false
        view.addSubview(loadErrorView)
        loadErrorView.backgroundColor = .white
        loadErrorView.translatesAutoresizingMaskIntoConstraints = false
        if (firstLoad == true) {
            loadErrorView.topAnchor.constraint(equalTo: placer.bottomAnchor, constant: 51).isActive = true
        } else {
            loadErrorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -86).isActive = true
        }
        loadErrorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadErrorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            loadErrorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadErrorView.heightAnchor.constraint(equalToConstant: 80)
        ])

        let LoadErrorLabel = UILabel(frame: .zero)
        LoadErrorLabel.text = "Could not load data"
        LoadErrorLabel.textColor = UIColor(rgb: 0x333333)
        LoadErrorLabel.font = UIFont.systemFont(ofSize: 16)
        LoadErrorLabel.textAlignment = .center
        loadErrorView.addSubview(LoadErrorLabel)
        LoadErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            LoadErrorLabel.leadingAnchor.constraint(equalTo: loadErrorView.leadingAnchor, constant: 24),
            LoadErrorLabel.centerXAnchor.constraint(equalTo: loadErrorView.centerXAnchor),
            LoadErrorLabel.topAnchor.constraint(equalTo: loadErrorView.topAnchor, constant: 21),
            LoadErrorLabel.bottomAnchor.constraint(equalTo: loadErrorView.bottomAnchor, constant: -40)
        ])
        
        let retryButton = UIButton(frame: .zero)
        retryButton.setTitle("Try again", for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        retryButton.setTitleColor(UIColor(rgb: 0x38A0FF), for: .normal)
        retryButton.addTarget(self, action: #selector(retryLoading), for: .touchUpInside)
        loadErrorView.addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: loadErrorView.leadingAnchor, constant: 150),
            retryButton.centerXAnchor.constraint(equalTo: loadErrorView.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: loadErrorView.topAnchor, constant: 44),
            retryButton.bottomAnchor.constraint(equalTo: loadErrorView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setUpSearchErrorView() {
        searchErrorView.isHidden = false
        view.addSubview(searchErrorView)
        searchErrorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchErrorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 81),
            searchErrorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            searchErrorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            searchErrorView.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        let SorryLabel = UILabel(frame: .zero)
        SorryLabel.text = "Sorry"
        SorryLabel.textColor = UIColor(rgb: 0x333333)
        SorryLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        SorryLabel.textAlignment = .center
        searchErrorView.addSubview(SorryLabel)
        SorryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            SorryLabel.centerXAnchor.constraint(equalTo: searchErrorView.centerXAnchor),
            SorryLabel.topAnchor.constraint(equalTo: searchErrorView.topAnchor)
        ])
        
        let searchErrorLabel = UILabel(frame: .zero)
        searchErrorLabel.text = "No result match this keyword"
        searchErrorLabel.textColor = UIColor(rgb: 0x999999)
        searchErrorLabel.font = UIFont.systemFont(ofSize: 16)
        searchErrorLabel.textAlignment = .center
        searchErrorView.addSubview(searchErrorLabel)
        searchErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchErrorLabel.centerXAnchor.constraint(equalTo: searchErrorView.centerXAnchor),
            searchErrorLabel.topAnchor.constraint(equalTo: searchErrorView.bottomAnchor)
        ])
    }
    
    @objc private func pullToRefresh(_ sender: AnyObject) {
        viewModel.coins.removeAll()
        viewModel.searchCoins.removeAll()
        
        activityViewIndicator.isHidden = false
        activityViewIndicator.color = UIColor.darkGray
        activityViewIndicator.startAnimating()
        tableView.addSubview(activityViewIndicator)
        
        if isSearching == false {
            coinsIndex.removeAll()
            coinsIndexStart = TOP_THREE
            coinsIndexDifference = 0
            coinsInterval = 5
            viewModel.setUpCoins()
            setUpCoinIndex()
        } else {
            searchCoinsIndex.removeAll()
            searchCoinsIndexStart = 0
            searchCoinsIndexDifference = 0
            searchCoinsInterval = 5
            viewModel.searchCoinsOffset = 0
            viewModel.continueSearchCoins()
            setUpSearchCoinIndex()
        }
        tableView.reloadData()
        activityViewIndicator.isHidden = true
        refreshControl.endRefreshing()
    }
    
    @objc private func clearSearch() {
        searchBar.text = ""
        viewModel.searchCoinsOffset = 0
        viewModel.currentSearchQuery = ""
        viewModel.searchCoins.removeAll()
        isSearching = false
        searchBar.resignFirstResponder()
        clearButton.isHidden = true
        tableView.isHidden = false
        searchErrorView.isHidden = true
        tableView.reloadData()
    }
    
    private func setUpCoinIndex() {
        for index in (coinsIndexStart + coinsIndexDifference)..<viewModel.coinsOffset {
            if (index - 2) != coinsInterval {
                coinsIndex.append(index - coinsIndexDifference)
                coinsIndexStart += 1
            } else {
                coinsIndex.append(-1)
                coinsIndexDifference += 1
                coinsInterval *= 2
            }
        }
    }
    private func setUpSearchCoinIndex() {
        for index in (searchCoinsIndexStart + searchCoinsIndexDifference)..<viewModel.searchCoinsOffset {
            if (index + 1) != searchCoinsInterval {
                searchCoinsIndex.append(index - searchCoinsIndexDifference)
                searchCoinsIndexStart += 1
            } else {
                searchCoinsIndex.append(-1)
                searchCoinsIndexDifference += 1
                searchCoinsInterval *= 2
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CoinsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.searchCoinsOffset = 0
        viewModel.searchCoins(query: "")
        setUpSearchCoinIndex()
        isSearching = true
        tableView.reloadData()
        
        clearButton.isHidden = false
    }
}

// MARK: - UITableViewDataSource

extension CoinsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (isSearching == false && isLoading == false) {
           return 2
        } else {
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isLoading == true) {
            return 1
        } else if (isSearching == false) {
            switch section {
            case 0:
                return 1
            default:
                return viewModel.coins.count - TOP_THREE
            }
        } else {
            return viewModel.searchCoins.count
        }
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIndex = indexPath.row
        let sectionIndex = indexPath.section
        
        if (isLoading == true) {
            // Loading
            let cell = UITableViewCell()
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else if (isSearching == false && sectionIndex == 0) {
            // TopThreeCoinsCell
            var cell: TopThreeCoinsCell? = tableView.dequeueReusableCell(withIdentifier: CellReuseId.tableCell1_id, for: indexPath) as? TopThreeCoinsCell
            if cell == nil {
                cell = TopThreeCoinsCell(style: .default, reuseIdentifier: CellReuseId.tableCell1_id)
            }
            if (viewModel.coins.count > 0) {
                cell?.setUpCell(with: Array(viewModel.coins[0...2]))
                cell?.callClickItem = { [unowned self] coinId in
                    self.getCoinDetail(coinId: coinId)
                }
            }
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell!
        } else if (isSearching == false && sectionIndex == 1) {
            // Home page
            if (indexPath.row == viewModel.coins.count - TOP_THREE - coinsIndexDifference) {
                // Next page
                startLoading()
                viewModel.continueSetUpCoins()
                setUpCoinIndex()
            }
            if (coinsIndex[cellIndex] >= 0) {
                // OtherCoinsCell
                var cell: OtherCoinsCell? = tableView.dequeueReusableCell(withIdentifier: CellReuseId.tableCell2_id) as? OtherCoinsCell
                if cell == nil {
                    cell = OtherCoinsCell(style: .default, reuseIdentifier: CellReuseId.tableCell2_id)
                }
                if (viewModel.coins.count > 0) {
                    cell?.setUpCell(with: viewModel.coins[coinsIndex[cellIndex]])
                    firstLoad = false
                }
                cell?.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell!
            } else {
                // InviteFriendCell
                var cell: InviteFriendCell? = tableView.dequeueReusableCell(withIdentifier: CellReuseId.tableCell3_id) as? InviteFriendCell
                if cell == nil {
                    cell = InviteFriendCell(style: .default, reuseIdentifier: CellReuseId.tableCell3_id)
                }
                if (viewModel.coins.count > 0) {
                    cell?.setUpCell()
                    firstLoad = false
                }
                cell?.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell!
            }
        } else {
            // Search page
            if (indexPath.row == viewModel.searchCoins.count - searchCoinsIndexDifference) {
                // Next Page
                startLoading()
                viewModel.continueSearchCoins()
                setUpSearchCoinIndex()
            }
            if (searchCoinsIndex[cellIndex] >= 0) {
                // OtherCoinsCell
                var cell: OtherCoinsCell? = tableView.dequeueReusableCell(withIdentifier: CellReuseId.tableCell2_id) as? OtherCoinsCell
                if cell == nil {
                    cell = OtherCoinsCell(style: .default, reuseIdentifier: CellReuseId.tableCell2_id)
                }
                if (viewModel.searchCoins.count > 0) {
                    cell?.setUpCell(with: viewModel.searchCoins[searchCoinsIndex[cellIndex]])
                    firstLoad = false
                }
                cell?.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell!
            } else {
                // InviteFriendCell
                var cell: InviteFriendCell? = tableView.dequeueReusableCell(withIdentifier: CellReuseId.tableCell3_id) as? InviteFriendCell
                if cell == nil {
                    cell = InviteFriendCell(style: .default, reuseIdentifier: CellReuseId.tableCell3_id)
                }
                if (viewModel.searchCoins.count > 0) {
                    cell?.setUpCell()
                    firstLoad = false
                }
                cell?.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLoading == true || (isSearching == false && section == 1) || isSearching == true {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 51))
            headerView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            headerView.backgroundColor = .white
            let headerLabel = UILabel(frame: CGRect(x: 16, y: 20, width: headerView.bounds.width, height: 19))
            headerLabel.text = "Buy, sell and hold crypto"
            headerLabel.textColor = .black
            headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            headerLabel.textAlignment = .left
            headerView.addSubview(headerLabel)
        } else {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
        }
        return headerView
    }
}

extension CoinsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading == true || (isSearching == false && section == 1) || isSearching == true {
            return 51.0
        } else {
            return 0.001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (isSearching == false && section == 1) || isSearching == true {
            if (isLoading == true) {
                return 56.0
            } else {
                return 0.001
            }
        } else {
            return 0.001
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellIndex = indexPath.row
        let sectionIndex = indexPath.section
        
        if (isSearching == false && sectionIndex == 1) {
            if (coinsIndex[cellIndex] >= 0) {
                let coin = viewModel.coins[coinsIndex[cellIndex]]
                self.getCoinDetail(coinId: coin.uuid)
            } else {
                openInviteView()
            }
        } else if (isSearching == true) {
            if (searchCoinsIndex[cellIndex] >= 0) {
                let coin = viewModel.searchCoins[searchCoinsIndex[cellIndex]]
                self.getCoinDetail(coinId: coin.uuid)
            } else {
                openInviteView()
            }
        }
    }
}

