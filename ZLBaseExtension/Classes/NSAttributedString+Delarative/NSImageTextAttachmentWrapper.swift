//
//  Attach.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2021/11/21.
//  Copyright © 2021 ZM. All rights reserved.
//

import UIKit
import Foundation
import YYText

public enum NSTextAttachmentWrapperAlignment: Int {
    case baseline
    case centerline
    case top
    case bottom
}

public class NSImageTextAttachmentWrapper: NSObject {

    var image: UIImage

    // 默认font
    var font: UIFont = UIFont.systemFont(ofSize: 14)

    // 图片大小
    var size: CGSize = CGSize.zero

    // 对齐方式
    var alignment: NSTextAttachmentWrapperAlignment = .baseline

    // 图片大小适应行高 true： size 将失效
    var fitLineHeight: Bool = false
    
    // 是否用于YYText
    var useInYYText: Bool = false

    public init(image: UIImage) {
        self.image = image
        super.init()
    }

    @discardableResult
    public func font(_ font: UIFont) -> NSImageTextAttachmentWrapper {
        self.font = font
        return self
    }

    @discardableResult
    public func size(_ size: CGSize) -> NSImageTextAttachmentWrapper {
        self.size = size
        return self
    }

    @discardableResult
    public func alignment(_ alignment: NSTextAttachmentWrapperAlignment) -> NSImageTextAttachmentWrapper {
        self.alignment = alignment
        return self
    }

    @discardableResult
    public func fitLineHeight(_ fitLineHeight: Bool) -> NSImageTextAttachmentWrapper {
        self.fitLineHeight = fitLineHeight
        return self
    }

    @discardableResult
    public func useInYYText(_ useInYYText: Bool) -> NSImageTextAttachmentWrapper {
        self.useInYYText = useInYYText
        return self
    }
}

public extension NSImageTextAttachmentWrapper {

    /**
     NSTextAttachment 基于 行 的 baseLine 布局图片，因此并不是居中的
     修改 bounds 属性，以调节图片的布局和大小
     */

    func textAttachment() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = image

        /// lineHeight = ascender - descender
        let lineHeight = font.lineHeight
        let ascender = font.ascender     /// 在baseline坐标系中，字符顶部的y值
        let descender = font.descender    /// 在baseline坐标系中，字符底部的y值

        var size = self.size
        if size == CGSize.zero {
            size = image.size
        }
        if fitLineHeight {
            if alignment == .baseline {
                size = CGSize(width: image.size.width * ascender / image.size.height, height: image.size.width * ascender / image.size.height)
            } else {
                size = CGSize(width: image.size.width * lineHeight / image.size.height, height: image.size.width * lineHeight / image.size.height)
            }
        }

        /// NSTextAttachment 的坐标系是以baseline作为x轴（自左向右），y轴垂直于baseline（自下而上），原点位于文本基线上的字形位置。
        var bounds = CGRect.zero
        switch alignment {
        case .baseline:
            bounds = CGRect(origin: CGPoint.zero, size: size)
        case .bottom:
            bounds = CGRect(origin: CGPoint(x: 0, y: descender), size: size)
        case .top:
            bounds = CGRect(origin: CGPoint(x: 0, y: ascender - size.height), size: size)
        case .centerline:
            bounds = CGRect(origin: CGPoint(x: 0, y: (ascender + descender - size.height) / 2 ), size: size)
        }
        attachment.bounds = bounds
        return attachment
    }
    
    
    /**
       YYText 中显示图片需要使用 NSTextAttachment
     */
    @objc dynamic func asYYMutableAttributedString() -> NSMutableAttributedString {
        let textAttachment = YYTextAttachment()
        textAttachment.content = image
        textAttachment.contentMode = .scaleToFill
        
        let attributeString = NSMutableAttributedString(string: "\u{FFFC}")
        attributeString.yy_setTextAttachment(textAttachment, range: NSRange(location: 0, length: attributeString.length))
        
        let lineHeight = font.lineHeight
        let ascender = font.ascender
        let descender = font.descender

        var size = self.size
        if size == CGSize.zero {
            size = image.size
        }
        if fitLineHeight {
            if alignment == .baseline {
                size = CGSize(width: image.size.width * ascender / image.size.height, height: image.size.width * ascender / image.size.height)
            } else {
                size = CGSize(width: image.size.width * lineHeight / image.size.height, height: image.size.width * lineHeight / image.size.height)
            }
        }
        
        
        /// YYTextRunDelegate 中 ascent ，descent 均为正值， lineHeight = ascent + descent
        let delegate = YYTextRunDelegate()
        delegate.width = size.width
        switch alignment {
        case .baseline:
            delegate.ascent = size.height
        case .bottom:
            delegate.ascent = size.height + descender
        case .centerline:
            delegate.ascent = size.height / 2 + (ascender - lineHeight / 2)
        case .top:
            delegate.ascent = ascender
        }
        delegate.descent = size.height - delegate.ascent
        
        if (delegate.ascent < 0) {
            delegate.ascent = 0;
            delegate.descent = size.height;
        }
        
        let delegateRef = delegate.ctRunDelegate()
        attributeString.yy_setRunDelegate(delegateRef, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}

extension NSImageTextAttachmentWrapper: NSAttributedStringConvertible {

    public func asAttributedString() -> NSAttributedString {
        self.asMutableAttributedString()
    }
    public func asMutableAttributedString() -> NSMutableAttributedString {
        if useInYYText {
            return self.asYYMutableAttributedString()
                .font(self.font)
        } else {
            return self.textAttachment()
                .asMutableAttributedString()
                .font(self.font)
        }
    }
}

public extension UIImage {
    func asImageTextAttachmentWrapper() -> NSImageTextAttachmentWrapper {
        NSImageTextAttachmentWrapper(image: self)
    }
}
