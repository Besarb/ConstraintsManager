//
//  ConstraintsManager.swift
//  ConstraintsManager
//
//  Created by Besarb Zeqiraj on 19.12.18.
//  Copyright © 2018 Besarb. All rights reserved.
//

import UIKit

public struct ConstraintsManager {
    
    /// Constraints list.
    public var constraints = [NSLayoutConstraint]()
    /// Default views used for constraints with visual format constraints.
    public var views: [String : AnyObject]
    /// Default metrics used for constraints with visual format constraints.
    public var metrics: [String : Any]
    
    /**
     Initializes a new constraints manager with default views used for visual format constraints.
     - Parameter views: Default views used for constraints with visual format constraints.
     */
    public init(views:[String : AnyObject]) {
        ConstraintsManager.prepareViews(views: views)
        self.views = views
        self.metrics = [:]
    }
    
    /**
     Initializes a new constraints manager with default metrics used for visual format constraints.
     - Parameter metrics: Default metrics used for constraints with visual format constraints.
     */
    public init(metrics: [String : Any] = [:]) {
        self.views = [:]
        self.metrics = metrics
    }
    
    /**
     Initializes a new constraints manager with default metrics and views used for visual format constraints.
     - Parameters:
     - views: Default views used for constraints with visual format constraints.
     - metrics: Default metrics used for constraints with visual format constraints.
     */
    public init(metrics: [String : Any], views:[String : AnyObject]) {
        ConstraintsManager.prepareViews(views: views)
        self.views = views
        self.metrics = metrics
    }
}

extension ConstraintsManager {
    public func activate() {
        NSLayoutConstraint.activate(constraints)
    }
    
    public func deactivate() {
        NSLayoutConstraint.deactivate(constraints)
    }
}

extension ConstraintsManager {
    public mutating func add(_ constraint: NSLayoutConstraint) {
        constraints.append(constraint)
    }
    
    public mutating func add(_ format: String, options opts: NSLayoutConstraint.FormatOptions = []) {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: opts, metrics: metrics, views: views)
        self.constraints += constraints
    }
    
    public mutating func add(_ format: String, options opts: NSLayoutConstraint.FormatOptions, toMetrics metrics: [String : Any], toViews views: [String : AnyObject]) {
        ConstraintsManager.prepareViews(views: views)
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: opts, metrics: metrics, views: views)
        self.constraints += constraints
    }
    
    public mutating func add(item view1: Any, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation, toItem view2: Any?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant c: CGFloat) {
        self.add(NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c))
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

// Helpers
private extension ConstraintsManager {
    static func prepareViews(views: [String : Any]) {
        views.forEach {
            guard let view = $0.value as? UIView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
