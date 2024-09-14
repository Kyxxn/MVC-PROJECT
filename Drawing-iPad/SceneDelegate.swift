//
//  SceneDelegate.swift
//  Drawing-iPad
//
//  Created by 박효준 on 9/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = ViewController()
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
}
