//
//  EventTableViewCell.swift
//  RowTime
//
//  Created by Paul Ventisei on 11/05/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import UIKit
import FirebaseStorageCache

class EventTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventShortDescription: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    var event_id: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func set(event: Event) {
        event_id = event.eventId
        eventName.text = event.eventName
        eventDate.text = String(event.eventDate)
        eventShortDescription.text = event.eventDesc
        let ref = Files.imageReference(imageName: event.eventImageName)
        eventImage.setImage(storageReference: ref) //This pulls the image from the storageReference in FirebaseStorage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
