//
//  SectionLabel.swift
//  HobbyQuest
//
//  Created by Monica Tran on 12/9/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

class SectionLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    //You can change the initial Section Label attributes here
    func initializeLabel() {
        
        //self.textAlignment = .left
        //let color = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1)
        let color = UIColor.darkText
        self.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.font = UIFont(name: "Helvetica Neue", size: 16)
        self.textColor = color
        
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}

@IBDesignable
extension SectionLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
}



//
//  VegaScrollFlowLayout.swift
//  Pods
//
//  Created by Ivan Hahanov on 9/5/17.
//
//
import UIKit

private let transformIdentity = CATransform3D(m11: 1, m12: 0, m13: 0, m14: 0,
                                              m21: 0, m22: 1, m23: 0, m24: 0,
                                              m31: 0, m32: 0, m33: 1, m34: 0,
                                              m41: 0, m42: 0, m43: 0, m44: 1)

open class VegaScrollFlowLayout: UICollectionViewFlowLayout {
    
    open var springHardness: CGFloat = 15
    open var isPagingEnabled: Bool = true
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var visibleIndexPaths = Set<IndexPath>()
    private var latestDelta: CGFloat = 0
    
    // MARK: - Initialization
    
    override public init() {
        super.init()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    // MARK: - Public
    
    open func resetLayout() {
        dynamicAnimator.removeAllBehaviors()
        prepare()
    }
    
    // MARK: - Overrides
    
    override open func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // expand the visible rect slightly to avoid flickering when scrolling quickly
        let expandBy: CGFloat = -100
        let visibleRect = CGRect(origin: collectionView.bounds.origin,
                                 size: collectionView.frame.size).insetBy(dx: 0, dy: expandBy)
        
        guard let visibleItems = super.layoutAttributesForElements(in: visibleRect) else { return }
        let indexPathsInVisibleRect = Set(visibleItems.map{ $0.indexPath })
        
        removeNoLongerVisibleBehaviors(indexPathsInVisibleRect: indexPathsInVisibleRect)
        
        let newlyVisibleItems = visibleItems.filter { item in
            return !visibleIndexPaths.contains(item.indexPath)
        }
        
        addBehaviors(for: newlyVisibleItems)
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        guard isPagingEnabled else {
            return latestOffset
        }
        
        let row = ((proposedContentOffset.y) / (itemSize.height + minimumLineSpacing)).rounded()
        
        let calculatedOffset = row * itemSize.height + row * minimumLineSpacing
        let targetOffset = CGPoint(x: latestOffset.x, y: calculatedOffset)
        return targetOffset
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let dynamicItems = dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
        dynamicItems?.forEach { item in
            let convertedY = item.center.y - collectionView.contentOffset.y    - sectionInset.top
            item.zIndex = item.indexPath.row
            transformItemIfNeeded(y: convertedY, item: item)
        }
        return dynamicItems
    }
    
    private func transformItemIfNeeded(y: CGFloat, item: UICollectionViewLayoutAttributes) {
        guard itemSize.height > 0, y < itemSize.height * 0.5 else {
            return
        }
        
        let scaleFactor: CGFloat = scaleDistributor(x: y)
        
        let yDelta = getYDelta(y: y)
        
        item.transform3D = CATransform3DTranslate(transformIdentity, 0, yDelta, 0)
        item.transform3D = CATransform3DScale(item.transform3D, scaleFactor, scaleFactor, scaleFactor)
        item.alpha = alphaDistributor(x: y)
        
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)!
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        let delta = newBounds.origin.y - scrollView.bounds.origin.y
        latestDelta = delta
        
        let touchLocation = collectionView!.panGestureRecognizer.location(in: collectionView)
        
        dynamicAnimator.behaviors.flatMap { $0 as? UIAttachmentBehavior }.forEach { behavior in
            let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
            attrs.center = getUpdatedBehaviorItemCenter(behavior: behavior, touchLocation: touchLocation)
            self.dynamicAnimator.updateItem(usingCurrentState: attrs)
        }
        return false
    }
    
    // MARK: - Utils
    
    private func removeNoLongerVisibleBehaviors(indexPathsInVisibleRect indexPaths: Set<IndexPath>) {
        //get no longer visible behaviors
        let noLongerVisibleBehaviours = dynamicAnimator.behaviors.filter { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            return !indexPaths.contains(item.indexPath)
        }
        
        //remove no longer visible behaviors
        noLongerVisibleBehaviours.forEach { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
            self.dynamicAnimator.removeBehavior(behavior)
            self.visibleIndexPaths.remove(item.indexPath)
        }
    }
    
    private func addBehaviors(for items: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView else { return }
        let touchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
        
        items.forEach { item in
            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            
            springBehaviour.length = 0.0
            springBehaviour.damping = 0.8
            springBehaviour.frequency = 1.0
            
            if !CGPoint.zero.equalTo(touchLocation) {
                item.center = getUpdatedBehaviorItemCenter(behavior: springBehaviour, touchLocation: touchLocation)
            }
            
            self.dynamicAnimator.addBehavior(springBehaviour)
            self.visibleIndexPaths.insert(item.indexPath)
        }
    }
    
    private func getUpdatedBehaviorItemCenter(behavior: UIAttachmentBehavior,
                                              touchLocation: CGPoint) -> CGPoint {
        let yDistanceFromTouch = fabs(touchLocation.y - behavior.anchorPoint.y)
        let xDistanceFromTouch = fabs(touchLocation.x - behavior.anchorPoint.x)
        let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / (springHardness * 100)
        
        let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
        var center = attrs.center
        if latestDelta < 0 {
            center.y += max(latestDelta, latestDelta * scrollResistance)
        } else {
            center.y += min(latestDelta, latestDelta * scrollResistance)
        }
        return center
    }
    
    // MARK: - Distribution functions
    
    /**
     Distribution function that start as a square root function and levels off when reaches y = 1.
     - parameter x: X parameter of the function. Current layout implementation uses center.y coordinate of collectionView cells.
     - parameter threshold: The x coordinate where function gets value 1.
     - parameter xOrigin: x coordinate of the function origin.
     */
    private func distributor(x: CGFloat, threshold: CGFloat, xOrigin: CGFloat) -> CGFloat {
        guard threshold > xOrigin else {
            return 1
        }
        var arg = (x - xOrigin)/(threshold - xOrigin)
        arg = arg <= 0 ? 0 : arg
        let y = sqrt(arg)
        return y > 1 ? 1 : y
    }
    
    private func scaleDistributor(x: CGFloat) -> CGFloat {
        return distributor(x: x, threshold: itemSize.height * 0.5, xOrigin: -itemSize.height * 5)
    }
    
    private func alphaDistributor(x: CGFloat) -> CGFloat {
        return distributor(x: x, threshold: itemSize.height * 0.5, xOrigin: -itemSize.height)
    }
    
    private func getYDelta(y: CGFloat) -> CGFloat {
        return itemSize.height * 0.5 - y
    }
}

import UIKit

public extension UICollectionView {
    /// A convenient way to create a UICollectionView and configue it with a CenteredCollectionViewFlowLayout.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the collection view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This frame is passed to the superclass during initialization.
    ///   - centeredCollectionViewFlowLayout: The `CenteredCollectionViewFlowLayout` for the `UICollectionView` to be configured with.
    public convenience init(frame: CGRect = .zero, centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout) {
        self.init(frame: frame, collectionViewLayout: centeredCollectionViewFlowLayout)
        decelerationRate = UIScrollViewDecelerationRateFast
    }
}

/// A `UICollectionViewFlowLayout` that _pages_ and keeps its cells centered, resulting in the _"carousel effect"_ 🎡
open class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = CGSize.zero
    private var lastScrollDirection: UICollectionViewScrollDirection!
    
    public override init() {
        super.init()
        scrollDirection = .horizontal
        lastScrollDirection = scrollDirection
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        guard let collectionView = collectionView else { return }
        
        // invalidate layout to center first and last
        let currentCollectionViewSize = collectionView.bounds.size
        if !currentCollectionViewSize.equalTo(lastCollectionViewSize) || lastScrollDirection != scrollDirection {
            let inset: CGFloat
            switch scrollDirection {
            case .horizontal:
                inset = (collectionView.bounds.size.width - itemSize.width) / 2
                collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                collectionView.contentOffset = CGPoint(x: -inset, y: 0)
            case .vertical:
                inset = (collectionView.bounds.size.height - itemSize.height) / 2
                collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
                collectionView.contentOffset = CGPoint(x: 0, y: -inset)
            }
            lastCollectionViewSize = currentCollectionViewSize
            lastScrollDirection = scrollDirection
        }
    }
    
    private func determineProposedRect(collectionView: UICollectionView, proposedContentOffset: CGPoint) -> CGRect {
        let size = collectionView.bounds.size
        let origin: CGPoint
        switch scrollDirection {
        case .horizontal:
            origin = CGPoint(x: proposedContentOffset.x, y: 0)
        case .vertical:
            origin = CGPoint(x: 0, y: proposedContentOffset.y)
        }
        return CGRect(origin: origin, size: size)
    }
    
    private func attributesForRect(
        collectionView: UICollectionView,
        layoutAttributes: [UICollectionViewLayoutAttributes],
        proposedContentOffset: CGPoint
        ) -> UICollectionViewLayoutAttributes? {
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedCenterOffset: CGFloat
        
        switch scrollDirection {
        case .horizontal:
            proposedCenterOffset = proposedContentOffset.x + collectionView.bounds.size.width / 2
        case .vertical:
            proposedCenterOffset = proposedContentOffset.y + collectionView.bounds.size.height / 2
        }
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes {
            guard attributes.representedElementCategory == .cell else { continue }
            guard candidateAttributes != nil else {
                candidateAttributes = attributes
                continue
            }
            
            switch scrollDirection {
            case .horizontal:
                if fabs(attributes.center.x - proposedCenterOffset) < fabs(candidateAttributes!.center.x - proposedCenterOffset) {
                    candidateAttributes = attributes
                }
            case .vertical:
                if fabs(attributes.center.y - proposedCenterOffset) < fabs(candidateAttributes!.center.y - proposedCenterOffset) {
                    candidateAttributes = attributes
                }
            }
        }
        return candidateAttributes
    }
    
    // swiftlint:disable line_length
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let proposedRect: CGRect = determineProposedRect(collectionView: collectionView, proposedContentOffset: proposedContentOffset)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect),
            let candidateAttributesForRect = attributesForRect(
                collectionView: collectionView,
                layoutAttributes: layoutAttributes,
                proposedContentOffset: proposedContentOffset
            ) else { return proposedContentOffset }
        
        var newOffset: CGFloat
        let offset: CGFloat
        switch scrollDirection {
        case .horizontal:
            newOffset = candidateAttributesForRect.center.x - collectionView.bounds.size.width / 2
            offset = newOffset - collectionView.contentOffset.x
            
            if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
                let pageWidth = itemSize.width + minimumLineSpacing
                newOffset += velocity.x > 0 ? pageWidth : -pageWidth
            }
            return CGPoint(x: newOffset, y: proposedContentOffset.y)
            
        case .vertical:
            newOffset = candidateAttributesForRect.center.y - collectionView.bounds.size.height / 2
            offset = newOffset - collectionView.contentOffset.y
            
            if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
                let pageHeight = itemSize.height + minimumLineSpacing
                newOffset += velocity.y > 0 ? pageHeight : -pageHeight
            }
            return CGPoint(x: proposedContentOffset.x, y: newOffset)
        }
    }
    
    var pageWidth: CGFloat {
        switch scrollDirection {
        case .horizontal:
            return itemSize.width + minimumLineSpacing
        case .vertical:
            return itemSize.height + minimumLineSpacing
        }
    }
    
    /// Programatically scrolls to a page at a specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the page to scroll to.
    ///   - animated: Whether the scroll should be performed animated.
    public func scrollToPage(index: Int, animated: Bool) {
        guard let collectionView = collectionView else { return }
        
        let pageOffset: CGFloat
        let proposedContentOffset: CGPoint
        let shouldAnimate: Bool
        switch scrollDirection {
        case .horizontal:
            pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.left
            proposedContentOffset = CGPoint(x: pageOffset, y: 0)
            shouldAnimate = fabs(collectionView.contentOffset.x - pageOffset) > 1 ? animated : false
        case .vertical:
            pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.top
            proposedContentOffset = CGPoint(x: 0, y: pageOffset)
            shouldAnimate = fabs(collectionView.contentOffset.y - pageOffset) > 1 ? animated : false
        }
        collectionView.setContentOffset(proposedContentOffset, animated: shouldAnimate)
    }
    
    /// Calculates the current centered page.
    public var currentCenteredPage: Int? {
        guard let collectionView = collectionView else { return nil }
        let currentCenteredPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width/2, y: collectionView.contentOffset.y + collectionView.bounds.height/2)
        let indexPath = collectionView.indexPathForItem(at: currentCenteredPoint)
        return indexPath?.row
    }
}
