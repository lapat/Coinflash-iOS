//
//  PortfolioViewController.swift
//  CoinFlash
//
//  Created by robert pham on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import SVProgressHUD
import MBProgressHUD

class PortfolioViewController: UIViewController, MainNewStoryboardInstance {
    
    let handler = PortfolioHandler()
    
    @IBOutlet weak var segmentedControl: CoinSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var lastRefreshDate: Date?
    var isLoadingData = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func appDidBecomeActive() {
        if self.tabBarController?.selectedIndex == 1 {
            if shouldRefreshDateIfExpired() {
                loadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefreshDateIfExpired() {
            loadData()
        }
    }
    
    func shouldRefreshDateIfExpired()-> Bool {
        guard let date = lastRefreshDate else {
            return true
        }
        let dif = Date().timeIntervalSince(date)
        if dif >= 300 {
            return true
        }
        return false
    }
    
    private func setupViews() {
        tableView.register(PortfolioSummaryCell.self)
        tableView.register(PortfolioPriceCell.self)
        tableView.register(PortfolioHistoryCell.self)
        tableView.register(PortfolioPieChartCell.self)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
    }

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    private func loadData() {
        if isLoadingData {
            return
        }
        isLoadingData = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        handler.requestCoinFlashFeatchwallet(mobile_secret: user_mobile_secret, user_id_mobile: user_id_mobile, mobile_access_token: user_mobile_access_token) { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.isLoadingData = false
            strongSelf.lastRefreshDate = Date()
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                if success {
                    self?.loadGraphData()
                } else {
                    
                }
            }
        }
    }

    private func loadGraphData() {
        handler.requestCryptoRates { [weak self] (success) in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension PortfolioViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let coin = segmentedControl.selectedCoin()
        if coin == .all {
            return 1
        }
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let coin = segmentedControl.selectedCoin()
        if section == 2 {
            if coin == .all {
                return handler.allTransactions.count
            } else {
                return handler.transactions[coin.rawValue]?.count ?? 0
            }
        } else if section == 1 {
            return 1
        }
        if coin == .all {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin = segmentedControl.selectedCoin()
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PortfolioSummaryCell
                if let json = handler.portfolioJSON {
                    cell.bindJson(json: json, type: segmentedControl.selectedIndex)
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PortfolioPieChartCell
                if let json = handler.portfolioJSON {
                    cell.bindJson(json: json)
                }
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PortfolioHistoryCell
            if segmentedControl.selectedIndex == 0 {
                let tran = handler.allTransactions[indexPath.row]
                cell.transaction = tran
            } else if let trans = handler.transactions[coin.rawValue] {
                let tran = trans[indexPath.row]
                cell.transaction = tran
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as PortfolioPriceCell
            cell.nameLabel.text = coin.name + " Price"
            if let json = handler.graphJson {
                cell.bindJson(json: json, coin: coin)
            }
            return cell
        }
        
        return UITableViewCell()
    }
}
