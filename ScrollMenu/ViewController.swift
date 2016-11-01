//
//  ViewController.swift
//  ScrollMenu
//
//  Created by yl on 2016/11/1.
//  Copyright © 2016年 YL. All rights reserved.
//

import UIKit
private let kTitleViewH : CGFloat = 40
class ViewController: UIViewController {
    // MARK:- 懒加载创建View
    fileprivate lazy var pageTitleView : YLPageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y:kStatusBarH + kNavigationBarH , width: kScreenW, height: kTitleViewH);
        let titles = ["推荐","游戏","娱乐","趣玩"];
        let titleView = YLPageTitleView(frame: titleFrame, titles: titles);
        titleView.delegate = self;
        return titleView;
    }();
    
    fileprivate lazy var pageContentView : YLPageContentView = {[weak self] in
        // 1.确定内容页面的Frame
        let contentViewH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH;
        let contentViewFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH + kTitleViewH, width: kScreenW, height: contentViewH);
        
        // 2.添加所有的子控制器
        var childVcs = [UIViewController]();
        for _ in 0..<4 {
            let childVC = UIViewController();
            childVC.view.backgroundColor = UIColor.randomColor();
            childVcs.append(childVC);
        }
        
        let pageContentView = YLPageContentView(frame: contentViewFrame, childVcs: childVcs, parentViewControlle: self);
        pageContentView.delegate = self;
        
        return pageContentView;
    }();
    override func viewDidLoad() {
        // 不需要调整UIScrollView的内边距
        automaticallyAdjustsScrollViewInsets = false;
        
        // 添加View
        view.addSubview(pageTitleView);
        view.addSubview(pageContentView);
    }
}

//MARK:- 遵守YLPageTitleViewDelegate协议
extension ViewController : YLPageTitleViewDelegate
{
    func pageTitleView(_ titleView: YLPageTitleView, selectedIndex index: Int) {
        pageContentView.setCurrentIndex(index);
    }
}

//MARK:- 遵守YLPageContentViewDelegate协议
extension ViewController : YLPageContentViewDelegate
{
    func pageContentView(_ contentView: YLPageContentView, progress: CGFloat, beforeTitleIndex: Int, targetTitleIndex: Int) {
        pageTitleView.setTitleChangeWithProgress(progress, beforeTitleIndex: beforeTitleIndex, targetTitleIndex: targetTitleIndex);
    }
}
