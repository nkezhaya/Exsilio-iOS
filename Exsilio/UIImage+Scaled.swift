//
//  UIImage+Scaled.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit

extension UIImage {
    func scaledTo(scale: Float) -> UIImage {
        return UIImage(CGImage: self.CGImage!,
                       scale: self.scale * CGFloat(scale),
                       orientation: self.imageOrientation)
    }

    func imageWithTint(tintColor: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height);

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        drawInRect(rect)

        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(ctx, CGBlendMode.SourceIn)
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor)
        CGContextFillRect(ctx, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext();
        
        return image;
    }
}