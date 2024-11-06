

import Foundation
import UIKit

enum K {
    static let greetingText = "О чем поговорим?"
    static func jostFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Jost",
                      size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
