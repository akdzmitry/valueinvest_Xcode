//
//  CustomTableViewCell.swift
//  valueinvest
//
//  Created by Dzmitry on 2023-01-04.
//

import SwipeCellKit
import Foundation
import UIKit

class CustomTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var cellViewTicker: UILabel!
    @IBOutlet weak var cellViewPriceTarget: UILabel!
    @IBOutlet weak var cellViewDate: UILabel!
}
