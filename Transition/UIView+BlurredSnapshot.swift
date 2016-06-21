//
//  UIView+BlurredSnapshot.swift
//  DerpCounter
//
//  Created by HerliHalim on 10/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

extension UIView {
    
    func blurredSnapshotImage(blurRadius: CGFloat, scaleFactor: CGFloat, tintColor: UIColor, offset: CGFloat) -> UIImage {
        
        let scaledOffset = offset * scaleFactor
        
        let viewBound = CGRectInset(bounds, -offset, -offset)
        
        var scaledViewBound = viewBound
        scaledViewBound.size.width *= scaleFactor
        scaledViewBound.size.height *= scaleFactor
        
        var drawBound = bounds
        drawBound.size.width *= scaleFactor
        drawBound.size.height *= scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(scaledViewBound.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(scaledOffset, scaledOffset));
        drawViewHierarchyInRect(drawBound, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        let radius = blurRadius * scaleFactor
        let blurredImage = UIImageEffects.imageByApplyingBlurToImage(image, withRadius: radius, tintColor: tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
        
        return blurredImage
    }
    
    func blurredSnapshotView(blurRadius: CGFloat, scaleFactor: CGFloat, tintColor: UIColor) -> UIView {
        let offset: CGFloat = 20
        
        let viewBound = CGRectInset(bounds, -offset, -offset)
        let image = blurredSnapshotImage(blurRadius, scaleFactor: scaleFactor, tintColor: tintColor, offset: offset)

        let imageView = UIImageView(frame: viewBound)
        imageView.image = image
        imageView.backgroundColor = UIColor.blackColor()
        imageView.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
        
        return imageView

    }
}
