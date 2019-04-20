//
//  SearchViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/09/02.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    let cellUp = ["Category", "Area"]
    var searchTableView:UITableView!
    var setCell = ""
    @IBOutlet weak var upView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140), style: .grouped)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isScrollEnabled = false
        self.view.addSubview(searchTableView)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTableView.frame.origin.y = upView.frame.maxY+5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellUp.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cellData = cellUp[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = cellData
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCell = cellUp[indexPath.row]
        if setCell == "Area" {
//20181117            performSegue(withIdentifier: "toSearchMore",sender: nil)
            performSegue(withIdentifier: "ToMap",sender: nil)
        } else if setCell == "Category"{
            performSegue(withIdentifier: "ToSCate",sender: nil)
        }
        
    }

    
}
