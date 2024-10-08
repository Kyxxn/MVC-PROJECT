//
//  ViewController.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/14/24.
//

import UIKit
import PhotosUI

final class CanvasViewController: UIViewController {
    // MARK: Properties
    
    private let canvasView = CanvasView()
    private var factory: (any ShapeCreatable)?
    private let plane = Plane()
    private var selectedShapeView: BaseShapeView?
    private var selectedShapeViewIndex: Int?
    private var temporaryView: UIView?
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        canvasView.delegate = self
        
        setupConfiguration()
        setupNotificationAddObserver()
    }
    
    // MARK: Method
    
    private func setupConfiguration() {
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotificationAddObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaneChanged),
            name: .planeUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShapeChanged),
            name: .shapeUpdated,
            object: nil
        )
    }
    
    @objc private func handlePlaneChanged() {
        print("CanvasViewController handlePlaneChanged")
    }
    
    @objc private func handleShapeChanged(_ notification: Notification) {
        if let updatedShape = notification.object as? BaseShape {
            canvasView.updateSideView(shape: updatedShape)
        }
    }
}

// MARK: - CanvasViewDelegate

extension CanvasViewController: CanvasViewDelegate {
    // MARK: ShapeModel & ShapeView Creator
    
    func didTapShapeCreatorButtonInCanvasView(_ canvasView: CanvasView, shapeCategory: ShapeCategory) {
        switch shapeCategory {
        case .rectangle:
            let shape = createRectangle()
            plane.appendShape(shape: shape)
        case .photo:
            presentPhotoPicker()
        }
    }
    
    private func createRectangle() -> BaseShape {
        let factory = RectangleFactory(viewBoundsSize: canvasView.planeViewBoundsSize())
        let rectangle = factory.makeShape()
        let rectangleView = RectangleView(shapeID: rectangle.identifier)
        rectangleView.setupFromModel(shape: rectangle)
        canvasView.addShape(shapeView: rectangleView)
        
        return rectangle
    }
    
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let phPickerViewController = PHPickerViewController(configuration: configuration)
        phPickerViewController.delegate = self
        present(phPickerViewController, animated: true)
    }
    
    // MARK: Tap Gesture
    
    func didTapGestureShapeView(_ canvasView: CanvasView, shapeID: UUID) {
        if let previousSelectedView = selectedShapeView {
            previousSelectedView.isSelected = false
        }
        
        guard let shapeView = canvasView.shapeView(withID: shapeID),
              let shape = plane.findShape(withID: shapeID) else { return }
        
        shapeView.isSelected = true
        selectedShapeView = shapeView
        
        canvasView.updateSideView(shape: shape)
    }
    
    // MARK: Pan Gesture
    
    func didPanGestureShapeView(_ canvasView: CanvasView, shapeID: UUID, sender: UIPanGestureRecognizer) {
        guard let shapeView = canvasView.shapeView(withID: shapeID) else { return }
        let translation = sender.translation(in: canvasView)
        
        switch sender.state {
        case .began:
            createTemporaryView(shapeView: shapeView)
        case .changed:
            if let tempView = temporaryView {
                tempView.center = CGPoint(
                    x: tempView.center.x + translation.x,
                    y: tempView.center.y + translation.y
                )
                sender.setTranslation(.zero, in: canvasView)
                updateShapeModelPosition(origin: tempView.frame.origin)
            }
        case .ended, .cancelled:
            shapeView.center = CGPoint(
                x: shapeView.center.x + translation.x,
                y: shapeView.center.y + translation.y
            )
            finishDragging(shapeView: shapeView)
            sender.setTranslation(.zero, in: canvasView)
        default:
            break
        }
    }
    
    func createTemporaryView(shapeView: BaseShapeView) {
        temporaryView = shapeView.snapshotView(afterScreenUpdates: false)
        temporaryView?.alpha = 0.5
        temporaryView?.center = shapeView.center
        canvasView.addShape(tempView: temporaryView!)
    }
    
    func finishDragging(shapeView: BaseShapeView) {
        guard let temporaryView = temporaryView else { return }
        temporaryView.removeFromSuperview()
        
        let origin = temporaryView.frame.origin
        let size = temporaryView.frame.size
        
        shapeView.updateFrame(origin: Point(x: origin.x, y: origin.y),
                              size: Size(width: size.width, height: size.height))
        updateShapeModelPosition(origin: shapeView.frame.origin)
    }
    
    func updateShapeModelPosition(origin: CGPoint) {
        guard let index = selectedShapeViewIndex,
              let shape = plane[index] else { return }
        
        shape.updateOrigin(x: origin.x, y: origin.y)
    }
    
    // MARK: SideView
    
    func didTapBackgroundColorChangeButton(_ canvasView: CanvasView) {
        guard let shapeView = selectedShapeView,
              let shape = plane.findShape(withID: shapeView.shapeID) as? Rectangle else { return }
        let newColor = RandomFactory.makeRandomColor()
        
        shapeView.backgroundColor = UIColor(
            red: CGFloat(newColor.red) / 255.0,
            green: CGFloat(newColor.green) / 255.0,
            blue: CGFloat(newColor.blue) / 255.0,
            alpha: selectedShapeView?.alpha ?? .zero
        )
        shape.updateColor(color: newColor)
    }
    
    func didChangeAlphaSlider(_ canvasView: CanvasView, changedValue: Float) {
        guard let shapeView = selectedShapeView,
              let shape = plane.findShape(withID: shapeView.shapeID) else { return }
        shapeView.alpha = CGFloat(changedValue) / 10.0
        
        if let newAlpha = Alpha.from(floatValue: changedValue) {
            shape.updateAlpha(alpha: newAlpha)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CanvasViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedimage = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                guard let documents = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first
                else { return }
                let fileName = UUID().uuidString + ".png"
                let imageURL = documents.appending(path: fileName, directoryHint: .notDirectory)
                self.createPhoto(image: selectedimage, imageURL: imageURL)
            }
        }
    }
    
    private func createPhoto(image: UIImage, imageURL: URL) {
        let factory = PhotoFactory(viewBoundsSize: canvasView.planeViewBoundsSize())
        let photo = factory.makeShape(imageURL: imageURL)
        
        let photoImageView = UIImageView(image: image)
        let photoView = PhotoView(imageView: photoImageView, shapeID: photo.identifier)
        photoView.setupFromModel(shape: photo)
        
        plane.appendShape(shape: photo)
        canvasView.addShape(shapeView: photoView)
    }
}
