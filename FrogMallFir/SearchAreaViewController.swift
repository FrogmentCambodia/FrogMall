//
//  SearchAreaViewController.swift
//  Frog Mall
//
//  Created by 阿瀬義弘 on 2018/11/17.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

class SearchAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let areaList = ["Phnom Penh ភ្នំពេញ","Takeo តាកែវ","Preah Sihanouk ព្រះសីហនុ","Battambang បាត់ដំបង","Siem Reap សៀមរាប","Others"]
    var setCell2 = ""
    var fromVC = ""
    var setTableView:UITableView!
    @IBAction func backFromArea(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var areaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView = UITableView(frame: view.frame, style: .grouped)
//        setTableView.frame.origin.y = areaLabel.frame.maxY + 5
        setTableView.isScrollEnabled = false
        setTableView.delegate = self
        setTableView.dataSource = self
        self.view.addSubview(setTableView)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTableView.frame.origin.y = areaLabel.frame.maxY + 12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return areaList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "AREA"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = UITableViewCell(style: .subtitle, reuseIdentifier: "cell2")
        cell2.textLabel?.text = areaList[indexPath.row]
/*
        let tableDatas01 = [categoryList]
        let tableDatas02 = [areaList]
        var sectionData2:Array<Any>
        if getCell == "Category" {
            sectionData2 = tableDatas01[(indexPath as NSIndexPath).section]
        } else {
            sectionData2 = tableDatas02[(indexPath as NSIndexPath).section]
        }
        let cellData2 = sectionData2[(indexPath as NSIndexPath).row]
        cell2.textLabel?.text = cellData2 as? String
 */
        cell2.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCell2 = areaList[indexPath.row]
        
        if fromVC != "FromUpload" {
            self.performSegue(withIdentifier: "ToSearchFromArea", sender: nil)
        } else if fromVC == "FromUpload" {
            self.performSegue(withIdentifier: "myRewindSegue3", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "ToSearchFromArea") {
            let SCVC: SearchCollectViewController = (segue.destination as? SearchCollectViewController)!
            SCVC.getArea = setCell2
            SCVC.getCate = ""
        } else if (segue.identifier == "myRewindSegue3") {
            let UPVC: UploadViewController = (segue.destination as? UploadViewController)!
            
            UPVC.section01 = [setCell2]
            UPVC.reloadCell()
        }
    }
    
}
