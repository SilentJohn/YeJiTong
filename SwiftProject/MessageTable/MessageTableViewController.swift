//
//  MessageTableViewController.swift
//  SwiftProject
//
//  Created by IOS on 2016/10/27.
//  Copyright © 2016年 IOS. All rights reserved.
//

import UIKit
import MBProgressHUD

class MessageTableViewController: UITableViewController {

    @IBOutlet weak var segGuestOrFellow: UISegmentedControl!
    @IBOutlet weak var btnHeadIcon: UIButton!
    
    let searchController: UISearchController = {
        let tempSearchController = UISearchController(searchResultsController: nil)
        tempSearchController.obscuresBackgroundDuringPresentation = false
        return tempSearchController
    }()

    var dataSource: [MessageModel] = []
    var filteredData: [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        requestForData()
    }
    
    private func setUpViews() {
        if let imagePath = SQLiteOperation.getMyData(key: headLocalURLKey) {
            if let image = UIImage(contentsOfFile: imagePath) {
                btnHeadIcon.setImage(image, for: .normal);
            } else {
                btnHeadIcon.setImage(#imageLiteral(resourceName: "personIconDefault.png"), for: .normal);
            }
        }
        
        segGuestOrFellow.clipsToBounds = true
        segGuestOrFellow.layer.cornerRadius = 14
        segGuestOrFellow.layer.borderWidth = 1
        segGuestOrFellow.layer.borderColor = UIColor.white.cgColor
        
        dataSource.append(MessageModel(dic: ["headImageUrl":"com.apple/somepic.png", "senderTitle":"江湧", "sendTime":"2016-10-27 18:40", "messageContent":"呲牙"]))
        tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func requestForData() {
        let deliverTimeStr = SQLiteOperation.getMyData(key: deliverTimeKey) ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var deliverTime = formatter.date(from: deliverTimeStr) ?? Date(timeIntervalSinceNow: -24 * 60 * 60)
        if deliverTime.addingTimeInterval(-24 * 60 * 60).compare(Date()) == .orderedAscending {
            deliverTime = Date(timeIntervalSinceNow: -24 * 60 * 60)
        }
        let contentDic: [String:String] = ["last_update_time":formatter.string(from: deliverTime)]
        NetRequestManager().send(contentDic: contentDic, tid: .TerminalGetAllMissChatMsgREQ, requestID: 0, success: { dic, tid, requestId in
            guard let rltCode = dic["rlt_code"] as? Int else {
                print("Invalid result code")
                return
            }
            switch rltCode {
            case 0:
                MBProgressHUD.show(error: "刷新失败", view: self.view)
            case 1:
                self.updateMessages()
            default:
                print("Invalid result code")
                MBProgressHUD.show(error: "刷新失败", view: self.view)
            }
        }, failure: { error, tid in
            print("\(error)")
        })
    }
    
    private func updateMessages() {
//        var array: [VisitorModel] = [VisitorModel]()
//        switch self.segGuestOrFellow.selectedSegmentIndex {
//        case 0:
//            
//        case 1:
//            
//        default:
//            break;
//        }
    }
    
    @IBAction func headImageAction(_ sender: UIButton) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredData.count
        } else {
            return dataSource.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        if searchController.isActive {
            cell.messageModel = filteredData[indexPath.row]
        } else {
            cell.messageModel = dataSource[indexPath.row]
        }
        return cell
    }

    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        dataSource.removeAll()
        switch sender.selectedSegmentIndex {
        case 0:
            dataSource.append(MessageModel(dic: ["headImageUrl":"com.apple/somepic.png", "senderTitle":"江湧", "sendTime":"2016-10-27 18:40", "messageContent":"呲牙"]))
            dataSource.append(MessageModel(dic: ["headImageUrl":"com.apple/somepic.png", "senderTitle":"呵呵", "sendTime":"2016-10-27 18:40", "messageContent":"呲牙"]))
        case 1:
            dataSource.append(MessageModel(dic: ["headImageUrl":"com.apple/somepic.png", "senderTitle":"dd夏永杰", "sendTime":"2016-10-27 18:45", "messageContent":"呵呵"]))
        default:
            break
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let backBarItem = UIBarButtonItem()
        backBarItem.title = "返回"
        navigationItem.backBarButtonItem = backBarItem
    }

}

extension MessageTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredData.removeAll()
        if searchController.searchBar.text == "" {
            filteredData = [MessageModel].init(dataSource)
        } else {
            filteredData = dataSource.filter {$0.senderTitle.range(of: searchController.searchBar.text!, options: .regularExpression) != nil}
        }
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        print("filteredData = \(filteredData)")
    }
}

extension MessageTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { 
            self.tabBarController?.tabBar.transform = CGAffineTransform(translationX: 0, y: (self.tabBarController?.tabBar.frame.height)!)
            }, completion: nil)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.tabBarController?.tabBar.transform = CGAffineTransform.identity
            }, completion: nil)
    }
}
