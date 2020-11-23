//
//  ConstraintsManager.swift
//  ConstraintsManager
//
//  Created by Besarb Zeqiraj on 19.12.18.
//  Copyright © 2018 Besarb. All rights reserved.
//

import UIKit

public struct ConstraintsManager {
    
    public enum Attribute {
        case leading(_ margin: CGFloat = 0)
        case trailing(_ margin: CGFloat = 0)
        case top(_ margin: CGFloat = 0)
        case bottom(_ margin: CGFloat = 0)
        case centerX(_ offset: CGFloat = 0)
        case centerY(_ offset: CGFloat = 0)
        
        case width(_ value: CGFloat = 0)
        case height(_ value: CGFloat = 0)
        
        case aboveOf(Any, _ margin: CGFloat = 0)
        case belowOf(Any, _ margin: CGFloat = 0)
        case rightOf(Any, _ margin: CGFloat = 0)
        case leftOf(Any, _ margin: CGFloat = 0)
        
        var name: String {
            switch self {
                case .top: return "top"
                case .bottom: return "bottom"
                case .leading: return "leading"
                case .trailing: return "trailing"
                case .centerX: return "centerX"
                case .centerY: return "centerY"
                case .width: return "width"
                case .height: return "height"
                default: return "other"
            }
        }
        
        var nsAttribute: NSLayoutConstraint.Attribute {
            switch self {
                case .leading(_): return NSLayoutConstraint.Attribute.leading
                case .trailing(_): return NSLayoutConstraint.Attribute.trailing
                case .top(_): return NSLayoutConstraint.Attribute.top
                case .bottom(_): return NSLayoutConstraint.Attribute.bottom
                case .centerX(_): return NSLayoutConstraint.Attribute.centerX
                case .centerY(_): return NSLayoutConstraint.Attribute.centerY
                default:
                    return NSLayoutConstraint.Attribute.notAnAttribute
            }
        }
        
        var constant: CGFloat {
            switch self {
                case let .leading(margin): return margin
                case let .trailing(margin): return margin
                case let .top(margin): return margin
                case let .bottom(margin): return margin
                case let .centerX(offset): return offset
                case let .centerY(offset): return offset
                case let .width(value): return value
                case let .height(value): return value
                default: return 0
            }
        }
    }
    
    public var constraints = [NSLayoutConstraint]()
    public let views: [String : AnyObject]?
    public let metrics: [String : Any]?
    
    public init(views:[String : AnyObject]? = nil, metrics: [String : Any]? = nil) {
        ConstraintsManager.prepareViews(views: views)
        self.views = views
        self.metrics = metrics
    }
    
    public func activate() {
        NSLayoutConstraint.activate(constraints)
    }
    
    public func deactivate(_ constraints: [NSLayoutConstraint]? = nil) {
        NSLayoutConstraint.deactivate(constraints ?? self.constraints)
    }
    
    public mutating func add(_ view: UIView, toItem: UIView? = nil, attributes: Attribute..., identifier: String? = nil) {
        for attribute in attributes {
            add(view, toItem: toItem, attribute: attribute, identifier: identifier)
        }
    }
    
    public mutating func add(_ view: UIView, toItem: UIView? = nil, attributesList: [Attribute], identifier: String? = nil) {
        for attribute in attributesList {
            add(view, toItem: toItem, attribute: attribute, identifier: identifier)
        }
    }
    
    private mutating func add(_ view: UIView, toItem: UIView?, attribute: Attribute, identifier: String? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        switch attribute {
            case .width(let value):
                self.add(view.widthAnchor.constraint(equalToConstant: value), identifier: identifier != nil ? "\(identifier!)_\(attribute.name)" : nil)
            
            case .height(let value):
                self.add(view.heightAnchor.constraint(equalToConstant: value), identifier: identifier != nil ? "\(identifier!)_\(attribute.name)" : nil)
            
            case .aboveOf(let ref, let margin):
                if let guide = ref as? UILayoutGuide {
                    add(view.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -margin), identifier: identifier != nil ? "\(identifier!)_top" : nil)
                }
                if let refView = ref as? UIView {
                    add(item: view, attribute: .bottom, toItem: refView, attribute: .top, constant: -margin, identifier: identifier)
                }
            
            case .belowOf(let ref, let margin):
                if let guide = ref as? UILayoutGuide {
                    add(view.topAnchor.constraint(equalTo: guide.topAnchor, constant: margin), identifier: identifier != nil ? "\(identifier!)_bottom" : nil)
                }
                if let refView = ref as? UIView {
                    add(item: view, attribute: .top, toItem: refView, attribute: .bottom, constant: margin, identifier: identifier)
                }
            
            case .leftOf(let ref, let margin):
                if let guide = ref as? UILayoutGuide {
                    add(view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: margin), identifier: identifier != nil ? "\(identifier!)_left" : nil)
                }
                if let refView = ref as? UIView {
                    add(item: view, attribute: .trailing, toItem: refView, attribute: .leading, constant: -margin, identifier: identifier)
                }
            
            case .rightOf(let ref, let margin):
                if let guide = ref as? UILayoutGuide {
                    add(view.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -margin), identifier: identifier != nil ? "\(identifier!)_right" : nil)
                }
                if let refView = ref as? UIView {
                    add(item: view, attribute: .leading, toItem: refView, attribute: .trailing, constant: margin, identifier: identifier)
                }
            
            case .centerX(let offset):
                let parentView = toItem ?? view.superview
                if offset > 0 && offset < 1 {
                    // Percentage placing
                    add(item: view, attribute: .centerX, toItem: parentView, attribute: .trailing, multiplier: offset, identifier: identifier != nil ? "\(identifier!)_\(attribute.name)" : nil)
                } else {
                    add(view.centerXAnchor.constraint(equalTo: parentView!.centerXAnchor, constant: offset), identifier: identifier != nil ? "\(identifier!)_\(attribute.name)" : nil)
                }
            
            default:
                let nsAttribute = attribute.nsAttribute
                var constant = attribute.constant
                if nsAttribute == .trailing || nsAttribute == .bottom {
                    constant *= -1
                }
                let parentView = toItem ?? view.superview
                self.add(item: view, attribute: nsAttribute, toItem: parentView, attribute: nsAttribute, constant: constant, identifier: identifier != nil ? "\(identifier!)_\(attribute.name)" : nil)
        }
    }
    
    public mutating func add(item view1: Any, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation = .equal, toItem view2: Any?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat = 1.0, constant c: CGFloat = 0.0, identifier: String? = nil){
        self.add(NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c), identifier: identifier)
    }
    
    public mutating func add(_ constraint: NSLayoutConstraint, priority: UILayoutPriority? = nil, identifier: String? = nil) {
        if priority != nil {
            constraint.priority = priority!
        }
        if identifier != nil {
            constraint.identifier = identifier!
        }
        constraints.append(constraint)
    }
    
    public mutating func add(_ format: String, options opts: NSLayoutConstraint.FormatOptions = [], metrics: [String : Any]? = nil, views: [String : AnyObject]? = nil) {
        ConstraintsManager.prepareViews(views: views)
        guard let views = views ?? self.views else {
            assertionFailure("ConstraintsManager is missing views")
            return
        }
        
        let metrics = metrics ?? self.metrics
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: opts, metrics: metrics, views: views)
        self.constraints += constraints
    }
    
    // Helpers
    
    private static func prepareViews(views: [String : Any]?) {
        views?.forEach {
            guard let view = $0.value as? UIView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

extension ConstraintsManager {
    
    public static func += (left: inout ConstraintsManager, right: String) {
        left.add(right)
    }
    
    public static func += (left: inout ConstraintsManager, right: NSLayoutConstraint) {
        left.add(right)
    }
    
    public static func += (left: inout ConstraintsManager, right: [NSLayoutConstraint]) {
        left.constraints += right
    }
    
    public static func += (left: inout ConstraintsManager, right: ConstraintsManager) {
        left.constraints += right.constraints
    }
}

//MARK: - Convenience methods
extension ConstraintsManager {
    
    /**
    Sets top/bottom/leading/trailing constraints to be the same as parent view.
    - parameter view: the view to constriant
    - parameter margins: the constant to be applied on top/bottom/leading/trailing constraints.
    */
    public mutating func add(_ view: UIView, margins: CGFloat = 0) {
        add(view, attributes: .leading(margins), .trailing(margins), .top(margins), .bottom(margins))
    }
    
    /**
    Sets top/bottom/leading/trailing constraints to be the same as a related view.
    - parameter view: the view to constriant
    - parameter related: the related view
    - parameter margins: the constant to be applied on top/bottom/leading/trailing constraints.
    */
    public mutating func same(_ view: UIView, as related: UIView, margins: CGFloat = 0) {
        sameWidth(view, as: related, margins: margins)
        sameHeight(view, as: related, margins: margins)
    }
    
    /**
    Sets leading/trailing constraints.
    - parameter view: the view to constriant
    - parameter related: the related view
    - parameter margins: the constant to be applied both on leading and trailing constraints.
    - parameter leadMargin: the constant to be applied to leading constraint
    - parameter trailMargin: the constant to be applied to trailing constraint
    - important: if `margins` is set and `leadMargin` and/or `trailMargin`, the bigger of two is used:
    
    `max(margins, leadMargin)`
    */
    public mutating func sameWidth(_ view: UIView, as related: UIView, margins: CGFloat = 0, leadMargin: CGFloat = 0, trailMargin: CGFloat = 0, identifier: String? = nil) {
        add(view, toItem: related, attributes: .leading(max(margins, leadMargin)), .trailing(max(margins, trailMargin)), identifier: identifier)
    }
    
    /**
    Sets top/bottom constraints.
    - parameter view: the view to constriant
    - parameter related: the related view
    - parameter margins: the constant to be applied both on top and bottom constraints.
    - parameter topMargin: the constant to be applied to top constraint
    - parameter bottomMargin: the constant to be applied to bottom constraint
    - important: if `margins` is set and `topMargin` and/or `bottomMargin`, the bigger of two is used:
    
    `max(margins, topMargin)`
    */
    public mutating func sameHeight(_ view: UIView, as related: UIView, margins: CGFloat = 0, topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, identifier: String? = nil) {
        add(view, toItem: related, attributes: .top(max(margins, topMargin)), .bottom(max(margins, bottomMargin)), identifier: identifier)
    }
    
    /**
    Sets centerX/centerY constraints to be the same as a related view.
    - parameter view1: the view to constriant
    - parameter view2: the related view
    */
    public mutating func center(_ view1: UIView, in view2: UIView, identifier: String? = nil) {
        add(view1, toItem: view2, attributes: .centerX(0), .centerY(0), identifier: identifier)
    }
    
    /**
    Sets width & height constraints for the specified view.
    - parameter view: the view to constriant
    - parameter width: the width in points
    - parameter height: the height in points
    */
    public mutating func size(_ view: UIView, width: CGFloat, height: CGFloat, identifier: String? = nil) {
        add(view, toItem: nil, attributes: .width(width), .height(height), identifier: identifier)
    }
    
    /// Retrieve constraints by theirs identifier
    /// - Parameter identifier: Constraint identifier
    public mutating func retrieveConstraints(for identifier: String) -> [NSLayoutConstraint] {
        return constraints.filter({ ($0.identifier?.contains(identifier) ?? false) })
    }
}
