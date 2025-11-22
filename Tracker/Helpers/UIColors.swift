import UIKit

enum TrackerColor: String, CaseIterable {
    case color1 = "1"
    case color2 = "2"
    case color3 = "3"
    case color4 = "4"
    case color5 = "5"
    case color6 = "6"
    case color7 = "7"
    case color8 = "8"
    case color9 = "9"
    case color10 = "10"
    case color11 = "11"
    case color12 = "12"
    case color13 = "13"
    case color14 = "14"
    case color15 = "15"
    case color16 = "16"
    case color17 = "17"
    case color18 = "18"
    
    var color: UIColor? {
        UIColor(named: rawValue)
    }
}
