//
//  TweakNightTheme.swift
//  ColoredVK2
//
//  Created by Даниил on 05.04.18.
//

import Foundation
import UIKit

struct vkm {
    class MessageBubbleView: UIView {}
    class MessageCell: UICollectionViewCell {}
    class HistoryCollectionViewController: UICollectionViewController {}
}

//extension vkm.HistoryCollectionViewController {
//    override class func initialize() {
//        
////        NSLog("[COLOREDVK2] %@", self.description())
//        let origSelector = class_getInstanceMethod(self, #selector(vkm.HistoryCollectionViewController.collectionView(_:cellForItemAt:)))
//        let swizzledSelector = class_getInstanceMethod(self, #selector(vkm.HistoryCollectionViewController.cvk_collectionView))
//        method_exchangeImplementations(origSelector, swizzledSelector)
//        
//        super.initialize();
//    }
//    
//    func cvk_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
//    {
//        let cell = cvk_collectionView(collectionView, cellForItemAt: indexPath)
//        NSLog("[COLOREDVK2] %@", cell.description)
//        
//        return cell
//    }
//}

extension vkm.MessageCell {
    override class func initialize() {
        let origLayoutSubviews = class_getInstanceMethod(self, #selector(UICollectionViewCell.layoutSubviews))
        let swizzledLayoutSubviews = class_getInstanceMethod(self, #selector(vkm.MessageCell.cvk_layoutSubviews))
        method_exchangeImplementations(origLayoutSubviews!, swizzledLayoutSubviews!)
        
        let origPrepareReuse = class_getInstanceMethod(self, #selector(UICollectionViewCell.prepareForReuse))
        let swizzledPrepareReuse = class_getInstanceMethod(self, #selector(vkm.MessageCell.cvk_prepareForReuse))
        method_exchangeImplementations(origPrepareReuse!, swizzledPrepareReuse!)
        
        super.initialize();
    }
    
    @objc func cvk_layoutSubviews() -> Void {
        setupBubble(self)
    }
    
    @objc func cvk_prepareForReuse() -> Void {
        setupBubble(self)
    }
}


func setupBubble(_ bubble: UIView) -> Void
{
    if (enabled.boolValue) {
        if enableNightTheme.boolValue {
            colorizeBubble(bubble, tintColor: cvkMainController.nightThemeScheme.incomingBackgroundColor)
        }
//        else if enabledMessagesImage.boolValue {
//            colorizeBubble(bubble, tintColor: messageBubbleTintColor)
//        } 
    }
}

func colorizeBubble(_ bubble: UIView, tintColor : UIColor) -> Void
{
    if bubble.responds(to: Selector(("bubbleView"))) {
        let bubbleView : UIView = bubble.perform(Selector(("bubbleView"))).takeUnretainedValue() as! UIView
        if bubbleView .isKind(of: UIView.self) {
            let bubbleLayer : CAShapeLayer = (bubbleView.layer as? CAShapeLayer)!
            if bubbleLayer.isKind(of: CAShapeLayer.self) {
                bubbleLayer.fillColor = tintColor.cgColor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    bubbleLayer.fillColor = tintColor.cgColor
                })
            }
        }
    }
}
