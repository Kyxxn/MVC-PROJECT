//
//  ShapeCreatable.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/20/24.
//

protocol ShapeCreatable {
    associatedtype ShapeType: BaseShape
    
    func makeShape() -> ShapeType
}
