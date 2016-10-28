//
//  UIImage+Extensions.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

import UIKit

extension UIImage {
    func scaledTo(_ scale: Float) -> UIImage {
        return UIImage(cgImage: self.cgImage!,
                       scale: self.scale * CGFloat(scale),
                       orientation: self.imageOrientation)
    }

    func imageWithTint(_ tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height);

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        draw(in: rect)

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setBlendMode(CGBlendMode.sourceIn)
        ctx?.setFillColor(tintColor.cgColor)
        ctx?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext();
        
        return image!;
    }

    func makeImageWithColorAndSize(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
