//
//  CrewTableViewCell.swift
//  RowTime
//
//  Created by Paul Ventisei on 06/05/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import UIKit

class CrewTableViewCell: UITableViewCell {

    // MARK: Properties
    

    @IBOutlet weak var crewName: UILabel!
    @IBOutlet weak var crewOarImage: UIImageView!
    @IBOutlet weak var crewCategory: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stopTime: UILabel!
    @IBOutlet weak var crewTime: UILabel!
    @IBOutlet weak var crewNumber: UILabel!
    @IBOutlet weak var CrewCellView: UIView!
    var crewSave: Crew?
    var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code

    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self,   selector: (#selector(CrewTableViewCell.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer (){
        crewTime.text = crewSave!.elapsedTime
        if !((crewSave?.inProgress!)!) {
            timer?.invalidate()
        }
    }
    func set(crew: Crew) {
        crewSave = crew
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm:ss.S"
        
        crewName.text = crew.crewName
        crewOarImage.image = UIImage(named: crew.picFile!)
        crewCategory.text = crew.category
        crewNumber.text = String(crew.crewNumber)
        if crew.startTimeLocal != nil {
            startTime.text = timeFormat.string(from: crew.startTimeLocal!)
        } else {
            startTime.text = "No time"
        }
        if crew.endTimeLocal != nil {
            stopTime.text = timeFormat.string(from: crew.endTimeLocal!)
        }else {
            stopTime.text = "No time"
        }
        
        crewTime.text = crew.elapsedTime
        runTimer()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
