//
//  RectangleView.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/17/24.
//

import UIKit

final class RectangleView: UIView {
    func setupFromModel(rectangle: Rectangle) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame.origin = rectangle.origin.toCGPoint
        self.frame.size = rectangle.size.toCGSize
        self.backgroundColor = UIColor(
            red: CGFloat(rectangle.color.red) / 255.0,
            green: CGFloat(rectangle.color.green) / 255.0,
            blue: CGFloat(rectangle.color.blue) / 255.0,
            alpha: rectangle.alpha.toCGFloat
        )
    }
}
