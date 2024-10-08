//
//  RectangleButton.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/15/24.
//

import UIKit

protocol ShapeCreatorButtonDelegate: AnyObject {
    func didTapShapeCreatorButton(_ button: ShapeCreatorButton,
                                  shapeCategory: ShapeCategory)
}

final class ShapeCreatorButton: UIButton {
    weak var delegate: ShapeCreatorButtonDelegate?
    
    private let name: String
    private let shapeCategory: ShapeCategory
    
    init(name: String, shapeCategory: ShapeCategory) {
        self.name = name
        self.shapeCategory = shapeCategory
        super.init(frame: .zero)
        setupConfiguration()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConfiguration() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 12
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(self.name, for: .normal)
        self.setTitleColor(UIColor.black, for: .normal)
        self.addAction(UIAction { [weak self] _ in
            self?.handleButtonTapped()
        }, for: .touchUpInside)
    }
    
    private func handleButtonTapped() {
        delegate?.didTapShapeCreatorButton(self, shapeCategory: self.shapeCategory)
    }
}
