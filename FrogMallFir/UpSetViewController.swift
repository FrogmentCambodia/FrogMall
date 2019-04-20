//
//  UpSetViewController.swift
//  FrogMallFir
//
//  Created by 阿瀬義弘 on 2018/08/08.
//  Copyright © 2018年 Frogment. All rights reserved.
//

import UIKit

class UpSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sectionUP2 = ["item category"]
    let sectionUP3 = ["area"]
    let categoryList = ["Sleeveless Blouse អាវអត់ដៃ","Short Sleeve Blouse អាវដៃខ្លី","Long Sleeve Blouse អាវដៃវែង","Work & Business Casual អាវកន្លែងការងារ","Long Skirts សំពត់វែង","Short Skirts សំពត់ខ្លី","Long Pants & Jeans ខោវែង","Short Pants & Jeans ខោខ្លី","Legwear ខោរឹប","Sleeveless Dress រ៉ូបអត់ដៃ","Short Sleeve Dress រ៉ូបដៃខ្លី","Long Sleeve Dress រ៉ូបដៃវែង","Maxi, Long រ៉ូបវែង","Party, wedding, occasion រ៉ូបកម្មវិធី","Wedding Gowns រ៉ូបកូនក្រមុំ","Jumpsuits ឈុតអាវជាប់ខោ","The Style (Two Pieces) មួយឈុត","Lingerie, bras ឈុតអាវក្នុង","Sleepwear & PJ អាវ និង ឈុតគេង","Swimsuit, beachwear ឈុតហែលទឹក","Costumes ឈុតប្លែកៗ","Thin Outerwear, Jacket អាវសកពីលើស្ដើង","Thick jacket, coat អាវក្រៅក្រាស់ រដូវត្រជាក់","Sweaters អាវចាក់រដូវរំហើយ","Pumps ស្បែកជើងកែងស្រួច","Boots ស្បែកជើងកខ្ពស់","Wedges ស្បែកជើងកែងជាប់","Flats ស្បែកជើងសកបាតរាប","Sandals, Flip-flop ស្បែកជើងផ្ទាត់","Active, Sneakers ស្បែកជើងកីឡា","Woman Socks ស្រោមជើងស្រី","Tote, Hobo កាបូបយួរដៃ","Shoulder, Satchel, Crossbody កាបូបយួរស្មា","Purse, Small Bag កាបូបដៃតូច","Work Bag កាបូបការងារ","Active, backpack កាបូប​យួរខ្នង","Female Belts ខ្សែក្រវ៉ាត់ស្រី","Brooch កន្លាស់អាវ","Scarf, gloves កន្សែងបង់កនិងស្រោមដៃ","Jewelry គ្រឿងអលង្ការ","Watch នាឡិកា","Hat & Hair មួកនិងសក់","Glasses វ៉ែនតា","Others"]
    let areaList = ["Phnom Penh ភ្នំពេញ","Preah Sihanouk ព្រះសីហនុ","Kampong Cham កំពង់ចាម","Siem Reap សៀមរាប","Battambang បាត់ដំបង","Kandal កណ្តាល","Banteay Meanchey បន្ទាយមានជ័យ","Kampong Chhnang កំពង់ឆ្នាំង","Kampong Speu កំពង់ស្ពឺ","Kampong Thom កំពង់ធំ","Kampot កំពត","Kep កែប","Koh Kong កោះកុង","Kratie ក្រចេះ","Mondulkiri មណ្ឌលគិរី","Otdar Meanchey ឧត្តមានជ័យ","Pailin ប៉ៃលិន","Preah Vihear ព្រះវិហារ","Prey Veng ព្រៃវែង","Pursat ពោធ៌សាត់","Ratanakiri រតនគីរី","Stung Treng ស្ទឹងត្រែង","Svay Rieng ស្វាយរៀង","Takeo តាកែវ","Tboung Khmum ត្បូងឃ្មុំ","Others"]
    var getCell = ""
    var setCell2 = ""
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBAction func backToUPS(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let setTableView:UITableView!
        setTableView = UITableView(frame: view.frame, style: .grouped)
        setTableView.frame.origin.y = naviBar.frame.maxY
        setTableView.delegate = self
        setTableView.dataSource = self
        self.view.addSubview(setTableView)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if getCell == "item category" {
                return categoryList.count
            } else {
                return areaList.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if getCell == "item category" {
                return sectionUP2[section]
            } else {
                return sectionUP3[section]
            }
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell2 = UITableViewCell(style: .subtitle, reuseIdentifier: "cell2")
        let tableDatas01 = [categoryList]
        let tableDatas02 = [areaList]
        var sectionData2:Array<Any>
        if getCell == "item category" {
            sectionData2 = tableDatas01[(indexPath as NSIndexPath).section]
        } else {
            sectionData2 = tableDatas02[(indexPath as NSIndexPath).section]
        }
        let cellData2 = sectionData2[(indexPath as NSIndexPath).row]
        cell2.textLabel?.text = cellData2 as? String
        cell2.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if getCell == "item category" {
            setCell2 = categoryList[indexPath.row]
        } else {
            setCell2 = areaList[indexPath.row]
        }
        self.performSegue(withIdentifier: "myRewindSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "myRewindSegue") {
            let UPVC: UploadViewController = (segue.destination as? UploadViewController)!
            
            if getCell == "item category" {
                UPVC.section00 = [setCell2]
            } else {
                UPVC.section01 = [setCell2]
            }
            UPVC.reloadCell()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
