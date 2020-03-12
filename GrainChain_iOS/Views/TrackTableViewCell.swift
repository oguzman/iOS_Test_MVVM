//
//  TrackTableViewCell.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/10/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import MapKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet private weak var lblName: UILabel!
    @IBOutlet private weak var lblDistance: UILabel!
    @IBOutlet private weak var lblTime: UILabel!

    public var trackCellViewModel: TrackTableCellViewModel? {
        didSet {
            lblName.text = trackCellViewModel?.nameText
            lblDistance.text = trackCellViewModel?.distanceText
            lblTime.text = trackCellViewModel?.durationText
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
