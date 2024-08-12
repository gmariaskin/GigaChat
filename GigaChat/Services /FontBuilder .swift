//
//  FontBuilder .swift
//  GigaChat
//
//  Created by Gleb on 05.08.2024.
//

import UIKit

class FontBuilder {
    
    static let shared = FontBuilder()
    
    func jost(size: CGFloat) -> UIFont {
        return UIFont(name: "Jost", size: size)!
    }
    
}

