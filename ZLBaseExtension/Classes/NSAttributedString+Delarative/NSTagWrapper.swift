//
//  NSTagWrapper.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2021/11/21.
//  Copyright © 2021 ZM. All rights reserved.
//

import UIKit
import CoreGraphics

public class NSTagWrapper: NSObject {

    var attributedString: NSAttributedString
    
    /// 标签的最大宽度
    var preferMaxWidth: CGFloat = .greatestFiniteMagnitude

    // 圆角
    var cornerRadius: CGFloat = 0
    var corner: UIRectCorner = .allCorners

    // border
    var borderColor: UIColor = UIColor.clear
    var borderWidth: CGFloat = 0

    //
    var backgroundColor: UIColor = UIColor.clear
    var backgroundImage: UIImage?
    var backgroundImageFrame: CGRect = .zero

    // 内
    var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    /// 是否用于YYText
    var useInYYText: Bool = false

    public init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
        super.init()
    }

    public convenience init(text: String) {
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.black])
        self.init(attributedString: attributedString)
    }

    public convenience override init() {
        self.init(attributedString: NSAttributedString())
    }

    public func asImage() -> UIImage? {

        let textSize = attributedString.boundingRect(with: CGSize(width: preferMaxWidth - edgeInsets.right - edgeInsets.left,
                                                                  height: .greatestFiniteMagnitude),
                                                     options: .usesLineFragmentOrigin,
                                                     context: nil)

        let textContainerSize = CGSize(width: ceil(textSize.width + edgeInsets.right + edgeInsets.left),
                                       height: ceil(textSize.height + edgeInsets.top + edgeInsets.bottom))
        let imageSize = CGSize(width: textContainerSize.width + 2 * borderWidth,
                               height: textContainerSize.height + 2 * borderWidth)
    
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let image = renderer.image { context in
            
            // 边框
            let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: borderWidth, y: borderWidth),
                                                        size: textContainerSize),
                                    byRoundingCorners: corner,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            if borderWidth != 0 {
                path.lineWidth = borderWidth
                borderColor.setStroke()
                path.stroke()
            }

            path.addClip()
            
            // 背景色
            backgroundColor.setFill()
            path.fill()
            
            // 背景图
            if let backgroundImage = backgroundImage {
                let frame = (self.backgroundImageFrame == .zero) ? CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height) :  self.backgroundImageFrame
                backgroundImage.draw(in: frame)
            }
            
            // 文字
            attributedString.draw(in: CGRect(x: edgeInsets.left + borderWidth,
                                             y: edgeInsets.top + borderWidth,
                                             width: ceil(textSize.width),
                                             height: ceil(textSize.height)))
            
        }
        
        return image
    }
}

public extension NSTagWrapper {

    @discardableResult
    func text(_ text: String) -> NSTagWrapper {
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.black])
        self.attributedString = attributedString
        return self
    }

    @discardableResult
    func attributedString(_ attributedString: NSAttributedString) -> NSTagWrapper {
        self.attributedString = attributedString
        return self
    }

    @discardableResult
    func cornerRadius(_ cornerRadius: CGFloat) -> NSTagWrapper {
        self.cornerRadius = cornerRadius
        return self
    }

    @discardableResult
    func corner(_ corner: UIRectCorner) -> NSTagWrapper {
        self.corner = corner
        return self
    }

    @discardableResult
    func borderColor(_ color: UIColor) -> NSTagWrapper {
        self.borderColor = color
        return self
    }

    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> NSTagWrapper {
        self.borderWidth = borderWidth
        return self
    }

    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor) -> NSTagWrapper {
        self.backgroundColor = backgroundColor
        return self
    }

    @discardableResult
    func backgroundImage(_ backgroundImage: UIImage) -> NSTagWrapper {
        self.backgroundImage = backgroundImage
        return self
    }

    @discardableResult
    func edgeInsets(_ edgeInsets: UIEdgeInsets) -> NSTagWrapper {
        self.edgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    func backgroundImageFrame(_ frame: CGRect) -> NSTagWrapper {
        self.backgroundImageFrame = frame
        return self
    }
    
    @discardableResult
    func preferMaxWidth(_ preferMaxWidth: CGFloat) -> NSTagWrapper {
        self.preferMaxWidth = preferMaxWidth
        return self
    }
    
    @discardableResult
    func useInYYText(_ useInYYText: Bool) -> NSTagWrapper {
        self.useInYYText = useInYYText
        return self
    }
}
