//
//  CycleScrollView.swift
//  CycleScrollView
//
//  Created by Loveletter on 14/03/2018.
//  Copyright © 2018 CodeTips. All rights reserved.
//

import UIKit

public enum ScrollDirection {
    case vertical
    case horizontal
}

public class CycleScrollView: UIView, UIScrollViewDelegate{
    
    private(set) var scrollView: UIScrollView!
    private var scrollDirection: ScrollDirection = .horizontal
    public weak var delegate: CycleScrollViewDelegate?
    
    var pagesCount: Int = 0
    var currentPageIndex: Int = 0 {
        didSet{
            pageControl.currentPage = currentPageIndex
        }
    }
    var contentViews = [UIView]()
    var animationTimer: Timer!
    var animationDuration: TimeInterval = 0.0
    
    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = UIColor.clear
        control.frame = CGRect(x: 50, y: self.bounds.height - 40, width: self.bounds.width - 100, height: 14)
        return control
    }()
    
    private var scrollViewStartContentOffsetX: CGFloat = 0.0
    private var scrollViewStartContentOffsetY: CGFloat = 0.0
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizesSubviews = true
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleTopMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin,
            .flexibleWidth,
            .flexibleHeight
        ]
        scrollView.contentMode = .center
        scrollView.contentSize = CGSize(width: 3 * scrollView.frame.width, height: scrollView.frame.height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }
    
    convenience public init(frame: CGRect , animation duration: TimeInterval) {
        self.init(frame: frame)
        if duration > 0.0{
            animationDuration = duration
            animationTimer = Timer.scheduledTimer(timeInterval: animationDuration, target: self, selector: #selector(animationTimerDidFired), userInfo: nil, repeats: true)
            animationTimer.pause()
        }
    }
    
    @objc func animationTimerDidFired(timer: Timer) {
        var newOffset = CGPoint.zero
        if scrollDirection == .horizontal {
            newOffset = CGPoint(x: 2 * scrollView.frame.width, y: scrollView.contentOffset.y)
        }
        else{
            newOffset = CGPoint(x: 0, y: 2 * scrollView.frame.height)
        }
        scrollView.setContentOffset(newOffset, animated: true)
    }
    
    public func reloadData() {
        self.configPages()
        self.configContentViews()
    }
    
    func configPages() {
        if let pages = delegate?.numberOfPages(in: self){
            pagesCount = pages
            if pagesCount > 1{
                scrollView.isScrollEnabled = true
                if scrollDirection == .horizontal{
                    scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
                }
                else
                {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollView.frame.width)
                }
                animationTimer.resumeAfter(interval: animationDuration)
                pageControl.numberOfPages = pagesCount
                self.addSubview(pageControl)
            }
            else{
                scrollView.isScrollEnabled = false
                pageControl.removeFromSuperview()
            }
        }
    }
    
    func configContentViews() {
        scrollView.subviews.forEach { $0.removeFromSuperview()}
        self.makeScrollViewContentDataSource()
        
        var counter: CGFloat = 0.0
        for view in contentViews {
            view.isUserInteractionEnabled = true
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction))
            view.addGestureRecognizer(longPressGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapAction))
            view.addGestureRecognizer(tapGesture)
            
            var rightRect = view.frame
            if scrollDirection == .horizontal{
                rightRect.origin = CGPoint(x: scrollView.frame.width * counter, y: 0)
            }
            else{
                rightRect.origin = CGPoint(x: 0, y: scrollView.frame.height * counter);
            }
            
            counter += 1
            view.frame = rightRect
            scrollView.addSubview(view)
        }
        
        if pagesCount > 1{
            if scrollDirection == .horizontal{
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            }
            else{
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.frame.height), animated: false)
            }
        }
        
    }
    
    func makeScrollViewContentDataSource() {
        let previousPageIndex = self.validNextPageIndex(with: currentPageIndex - 1)
        let rearPageIndex = self.validNextPageIndex(with: currentPageIndex + 1)
        
        contentViews.removeAll()
        
        let array = [previousPageIndex, currentPageIndex, rearPageIndex]
        let indexs =  (pagesCount == 1) ? Array(Set(array)) : array
        
        for index in indexs {
            guard self.isValidPage(index: index) else{
                return
            }
            
            let view = delegate?.cycleScrollView(self, viewForPageAt: index)
            if let v = view{
                contentViews.append(v)
            }
        }
    }
    
    
    func isValidPage(index: Int) -> Bool {
        if index >= 0, index <= pagesCount - 1 {
            return true
        }
        return false
    }
    
    func validNextPageIndex(with index: Int) -> Int {
        if index == -1{
            return pagesCount - 1
        }
        else if index == pagesCount{
            return 0
        }
        else{
            return index
        }
    }
    
    @objc func longPressGestureAction(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            animationTimer.pause()
        }
        
        if sender.state == .ended {
            animationTimer.resume()
        }
    }
    
    @objc func contentViewTapAction(sender: UITapGestureRecognizer) {
        if (delegate?.responds(to: #selector(CycleScrollViewDelegate.cycleScrollView(_:didSelectPageAt:))))!{
            delegate!.cycleScrollView!(self, didSelectPageAt: currentPageIndex)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewStartContentOffsetX = scrollView.contentOffset.x;
        scrollViewStartContentOffsetY = scrollView.contentOffset.y;
        animationTimer.pause()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        animationTimer.resumeAfter(interval: animationDuration)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDirection == .horizontal {
            let contentOffsetX = scrollView.contentOffset.x;
            if (pagesCount == 2) {
                if (scrollViewStartContentOffsetX < contentOffsetX) {
                    let tempView = contentViews.last
                    tempView?.frame = CGRect(origin: CGPoint(x: 2 * scrollView.frame.width, y: 0), size: (tempView?.frame.size)!)
                } else if (scrollViewStartContentOffsetX > contentOffsetX) {
                    let tempView = contentViews.first
                    tempView?.frame = CGRect(origin: CGPoint.zero, size: (tempView?.frame.size)!)
                }
            }
            
            if(contentOffsetX >= (2 * scrollView.frame.width)) {
                currentPageIndex = self.validNextPageIndex(with: currentPageIndex + 1)
                self.configContentViews()
            }
            if(contentOffsetX <= 0) {
                currentPageIndex = self.validNextPageIndex(with: currentPageIndex - 1)
                self.configContentViews()
            }
        }
        else{
            let contentOffsetY = scrollView.contentOffset.y;
            if (pagesCount == 2) {
                if (scrollViewStartContentOffsetY < contentOffsetY) {
                    let tempView = contentViews.last
                    tempView?.frame = CGRect(origin: CGPoint(x: 0, y: 2 * scrollView.frame.height), size: (tempView?.frame.size)!)
                } else if (scrollViewStartContentOffsetY > contentOffsetY) {
                    let tempView = contentViews.first
                    tempView?.frame = CGRect(origin: CGPoint.zero, size: (tempView?.frame.size)!)
                }
            }
            
            if(contentOffsetY >= (2 * scrollView.frame.height)) {
                currentPageIndex = self.validNextPageIndex(with: currentPageIndex + 1)
                self.configContentViews()
            }
            if(contentOffsetY <= 0) {
                currentPageIndex = self.validNextPageIndex(with: currentPageIndex - 1)
                self.configContentViews()
            }
        }
    }
    
    public func stopAutoScroll() {
        animationTimer.pause()
    }
    
    public func resumeAutoScroll() {
        animationTimer.resumeAfter(interval: animationDuration)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
