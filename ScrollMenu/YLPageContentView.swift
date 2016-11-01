//
//  YLPageContentView.swift
//  YLDouYuZB
//
//  Created by yl on 16/9/26.
//  Copyright © 2016年 yl. All rights reserved.
//

import UIKit

private let cellID = "cellID";

protocol YLPageContentViewDelegate : class {
    
    func pageContentView(_ contentView:YLPageContentView, progress:CGFloat,beforeTitleIndex:Int,targetTitleIndex:Int);
}

class YLPageContentView: UIView {
    
    // MARK:- 定义属性,来保存传进来的内容
    fileprivate var childVcs: [UIViewController];
    fileprivate weak var parentViewControlle: UIViewController?;
    fileprivate var startOffsetX : CGFloat = 0;
    
    fileprivate var isForbidScrollDelegate : Bool = false;
    // 代理属性
    weak var delegate : YLPageContentViewDelegate?;
    
    // MARK:- 懒加载属性
    fileprivate lazy var collectionView: UICollectionView = {[weak self] in
        // 1.创建layout
        let layout = UICollectionViewFlowLayout();
        layout.itemSize = (self?.bounds.size)!;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = .horizontal;
        
        // 2.创建UICollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout);
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.isPagingEnabled = true;
        collectionView.bounces = false;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID);
        
        return collectionView;
    }();
    
    // MARK:- 自定义构造函数
    init(frame: CGRect,childVcs: [UIViewController],parentViewControlle: UIViewController?) {
        
        self.childVcs = childVcs;
        self.parentViewControlle = parentViewControlle;
        
        super.init(frame: frame);
        
        // 设置UI界面
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK:- 设置UI界面
extension YLPageContentView {
    fileprivate func setupUI(){
        // 1.将所欲的子控制器添加到父控制器当中
        for childVc in childVcs{
            parentViewControlle?.addChildViewController(childVc);
        }
        
        // 2.添加UICollectionView，用于在cell中存放控制器的View
        addSubview(collectionView);
        collectionView.frame = bounds;
    }
    
}

// MARK:- 遵守UICollectionView的datasource协议
extension YLPageContentView:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.创建cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath);
        
        // 2.给cell设置内容
        let childVC = childVcs[(indexPath as NSIndexPath).item];
        childVC.view.frame = self.bounds;
        cell.contentView.addSubview(childVC.view);
        
        return cell;
    }
}

// MARK:- 遵守UICollectionoViewDelegate协议
extension YLPageContentView:UICollectionViewDelegate {
    /*
        这里我们要拿到collectionView的偏移量,要判断是向左滑动还是向右滑动（需要知道开始滑动的那一刻的偏移量和滑动过之后的偏移量这里就需要实现scrollView的begin代理方法了），还要拿到滑动后的Index和滑动进度progress
        这里面我们需要监听ScrollView的滚动就可以，因为我们的collectionView在scrolleview上放着呢
    
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       
        isForbidScrollDelegate = false;
        
        startOffsetX = scrollView.contentOffset.x;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 0.判断是点击还是滑动（判断是否是点击事件）
        if isForbidScrollDelegate {
            return;
        }
        
        // 1.定义需要获取到的数据
        var progress : CGFloat = 0;
        var beforeTitleIndex : Int = 0;
        var targetTitleIndex : Int = 0;
        
        // 2.判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x; // 当前的偏移量
        let scrollViewW = scrollView.bounds.width;
        if startOffsetX < currentOffsetX { // 左滑
            
            // 1.计算progress进度  (floor函数表示取整)
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
            
            // 2.计算beforeTitleIndex(之前的title的下标)
            beforeTitleIndex = Int(currentOffsetX / scrollViewW);
            
            // 3.计算targetTitleIndex(是要滑动到哪个位置的下标)
            targetTitleIndex = beforeTitleIndex + 1;
            // 这里要做一下判断，防止滚到最后的时候越界
            if targetTitleIndex >= childVcs.count {
                targetTitleIndex = childVcs.count - 1;
            }
            
            // 4.如果完全滑过去的时候将要改变我们的progress/beforeTitleIndex/targetTitleIndex
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1.0;
                targetTitleIndex = beforeTitleIndex;
            }
            
        } else { // 向右滑
            
            // 1. 计算progress滚动进度
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
            
            // 2.计算targetTitleIndex
            targetTitleIndex = Int(currentOffsetX / scrollViewW);
            
            // 3.计算beforeTitleIndex
            beforeTitleIndex = targetTitleIndex + 1;
            if beforeTitleIndex >= childVcs.count {
                beforeTitleIndex = childVcs.count - 1;
            }

        }

        // 4.将我们拿到的progress/beforeTitleIndex/targetTitleIndex传递给titleView
        delegate?.pageContentView(self, progress: progress, beforeTitleIndex: beforeTitleIndex, targetTitleIndex: targetTitleIndex);
        
    }
}

// MRAK:- 对外暴露的方法
extension YLPageContentView{
    func setCurrentIndex(_ currentIndex : Int){
        
        // 1.记录需要禁止的代理方法
        isForbidScrollDelegate = true;
        
        // 2.contentView滚到正确的位置
        let offsetX = CGFloat(currentIndex) * collectionView.frame.width;
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false);
    }
}












