//
//  UIView+AddSubviews.swift
//  GigaChat
//
//  Created by Nikita Stepanov on 31.08.2024.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
