//
//  CustomTableViewCell.swift
//  taskapp
//
//  Created by 石田悠 on 2020/04/28.
//  Copyright © 2020 yuu.ishida. All rights reserved.
//

// MARK: -　CustomでTableViewCellを作成
import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var mytextLabel: UILabel!
    @IBOutlet weak var mydetailLabel: UILabel!
    @IBOutlet weak var myCustomLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
