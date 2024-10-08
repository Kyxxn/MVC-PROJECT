//
//  RectangleFactory.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/15/24.
//

import Foundation

struct RectangleFactory: ShapeCreatable {
    let planeSize: CGSize
    
    init(viewBoundsSize: CGSize) {
        self.planeSize = viewBoundsSize
    }
    
    func makeShape() -> Rectangle {
        return Rectangle(
            origin: RandomFactory.makeRandomOrigin(size: planeSize),
            size: RandomFactory.makeRandomSize(),
            color: RandomFactory.makeRandomColor(),
            alpha: RandomFactory.makeRandomAlpha()
        )
    }
}
