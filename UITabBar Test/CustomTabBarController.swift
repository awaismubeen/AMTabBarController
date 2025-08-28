//
//  CustomTabBarController.swift
//  UITabBar Test
//
//  Created by Macgenics on 28/08/2025.
//

import UIKit

class AMTabBarController: UITabBarController {
    
    private let customTabBarView = UIView()
    private var buttons: [UIButton] = []
    private let items = ["house", "person", "gear"]
    
    private var shapeLayer: CAShapeLayer?
    private var selectedIndexCustom: Int = 0 {
        didSet { updateSelection(animated: true) }
    }
    private var currentWaveCenterX: CGFloat = 0
    private var isInitialSetupDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only setup the wave once after layout is complete
        if !isInitialSetupDone && !buttons.isEmpty {
            setupInitialWavePosition()
            isInitialSetupDone = true
        }
    }
    
    private func setupInitialWavePosition() {
        // Set initial wave position to the first tab
        if let firstButton = buttons.first {
            currentWaveCenterX = firstButton.center.x
            createShapeLayer()
            updateSelection(animated: false)
        }
    }
    
    private func setupCustomTabBar() {
        tabBar.isHidden = true
        customTabBarView.backgroundColor = .clear
        view.addSubview(customTabBarView)
        
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBarView.heightAnchor.constraint(equalToConstant: 90),
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Buttons
        let buttonWidth: CGFloat = 60
        let spacing = (UIScreen.main.bounds.width - (CGFloat(items.count) * buttonWidth)) / CGFloat(items.count + 1)
        
        for (index, iconName) in items.enumerated() {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: iconName), for: .normal)
            btn.tintColor = .white
            btn.tag = index
            
            let xPos = spacing + CGFloat(index) * (buttonWidth + spacing)
            btn.frame = CGRect(x: xPos, y: 25, width: buttonWidth, height: buttonWidth) // Start at higher position
            
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            
            buttons.append(btn)
            customTabBarView.addSubview(btn)
        }
    }
    
    private func createShapeLayer() {
        // Remove existing shape layer if any
        shapeLayer?.removeFromSuperlayer()
        
        let shape = CAShapeLayer()
        shape.path = createPathForPosition(currentWaveCenterX)
        shape.fillColor = UIColor.black.cgColor
        shape.shadowColor = UIColor.black.cgColor
        shape.shadowOpacity = 0.2
        shape.shadowRadius = 5
        shape.shadowOffset = CGSize(width: 0, height: -2)
        
        customTabBarView.layer.insertSublayer(shape, at: 0)
        shapeLayer = shape
    }
    
    private func createPath() -> CGPath {
        let height: CGFloat = 40.0
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: currentWaveCenterX - height * 2, y: 0))
        
        // First curve going down (inward)
        path.addCurve(to: CGPoint(x: currentWaveCenterX, y: height),
                      controlPoint1: CGPoint(x: currentWaveCenterX - 40, y: 0),
                      controlPoint2: CGPoint(x: currentWaveCenterX - 30, y: height))
        
        // Second curve going up (back to top)
        path.addCurve(to: CGPoint(x: currentWaveCenterX + height * 2, y: 0),
                      controlPoint1: CGPoint(x: currentWaveCenterX + 30, y: height),
                      controlPoint2: CGPoint(x: currentWaveCenterX + 40, y: 0))
        
        // Complete and close the rect path
        path.addLine(to: CGPoint(x: customTabBarView.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: customTabBarView.frame.size.width, y: customTabBarView.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: customTabBarView.frame.size.height))
        path.close()
        
        return path.cgPath
    }
    
    private func updateShapeLayerPath() {
        shapeLayer?.path = createPath()
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        selectedIndexCustom = sender.tag
        selectedIndex = sender.tag
        
        // Animate the wave movement from current position to new position
        animateWaveToPosition(at: sender.center.x)
    }
    
    private func animateWaveToPosition(at centerX: CGFloat) {
        guard let shapeLayer = shapeLayer else { return }
        
        // Ensure we're animating from the current position, not the initial one
        let currentPath = createPathForPosition(currentWaveCenterX)
        let targetPath = createPathForPosition(centerX)
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = currentPath
        animation.toValue = targetPath
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: "pathAnimation")
        
        // Update the current wave position and final path
        currentWaveCenterX = centerX
        shapeLayer.path = targetPath
    }
    
    private func createPathForPosition(_ centerX: CGFloat) -> CGPath {
        let height: CGFloat = 40.0
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: centerX - height * 2, y: 0))
        
        // First curve going down (inward)
        path.addCurve(to: CGPoint(x: centerX, y: height),
                      controlPoint1: CGPoint(x: centerX - 40, y: 0),
                      controlPoint2: CGPoint(x: centerX - 30, y: height))
        
        // Second curve going up (back to top)
        path.addCurve(to: CGPoint(x: centerX + height * 2, y: 0),
                      controlPoint1: CGPoint(x: centerX + 30, y: height),
                      controlPoint2: CGPoint(x: centerX + 40, y: 0))
        
        // Complete and close the rect path
        path.addLine(to: CGPoint(x: customTabBarView.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: customTabBarView.frame.size.width, y: customTabBarView.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: customTabBarView.frame.size.height))
        path.close()
        
        return path.cgPath
    }
    
    private func updateSelection(animated: Bool) {
        for (index, btn) in buttons.enumerated() {
            if index == selectedIndexCustom {
                btn.backgroundColor = .systemBlue
                btn.tintColor = .white
                btn.layer.cornerRadius = btn.frame.width / 2
                
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        btn.center.y = 0 // Move to dip level
                    }
                    animateWaveToPosition(at: btn.center.x)
                } else {
                    btn.center.y = 0 // Position at dip level
                    currentWaveCenterX = btn.center.x
                    shapeLayer?.path = createPathForPosition(btn.center.x)
                }
                customTabBarView.bringSubviewToFront(btn)
            } else {
                btn.backgroundColor = .clear
                btn.tintColor = .white
                btn.layer.cornerRadius = 0
                
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        btn.center.y = 25 // Move to higher position
                    }
                } else {
                    btn.center.y = 25 // Position at higher level
                }
            }
        }
    }
}
