//
//  YLPageTitleView.swift
//  YLDouYuZB
//
//  Created by yl on 16/9/21.
//  Copyright © 2016年 yl. All rights reserved.
//

import UIKit

// MARK:- 定义协议
// 写 :class 主要是表示只想让类遵守这个协议
protocol YLPageTitleViewDelegate : class {
    // 其中selectedIndex是表示一个外部参数，index则表示一个内部参数
    func pageTitleView(_ titleView : YLPageTitleView,selectedIndex index : Int);
}

// MARK:- 定义常量
private let kScrollLineH : CGFloat = 2;
// 通过元组来设置颜色值
private let kNormalColor : (CGFloat,CGFloat,CGFloat) = (85,85,85);
private let kSelectColor : (CGFloat,CGFloat,CGFloat) = (255,128,0);

// MARK:- 定义YLPageTitleView类
class YLPageTitleView: UIView {

    // 定义属性 -- 这里的定义属性，相当于OC中的@property(strong,)定义属性
    fileprivate var currentIndex : Int = 0;
    fileprivate var titles : [String];
    weak var delegate : YLPageTitleViewDelegate?
    
    // 懒加载属性
    fileprivate lazy var titleScrollView : UIScrollView = {
        let scrollView = UIScrollView();
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.scrollsToTop = false;
        scrollView.bounces = false;
        return scrollView;
    }();
    
    fileprivate lazy var scrollLine : UIView = {
        let scrollLine = UIScrollView();
        scrollLine.backgroundColor = UIColor.orange;
        return scrollLine;
    }();
    
    fileprivate lazy var titleLabels : [UILabel] = [UILabel]();
    
    /**
     *  自定义构造函数  (swfit中自定义构造函数的时候必须重写init?coder函数(required init?(coder aDecoder: NSCoder)))
     */
    init(frame: CGRect,titles:[String]) {
        self.titles = titles;
        
        super.init(frame: frame);
        
        // 设置UI界面
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension YLPageTitleView{
    
    fileprivate func setupUI(){
        // 1.添加UIScrollView
        addSubview(titleScrollView);
        titleScrollView.frame = bounds;
        
        // 2.添加title对应的Label
        setupTitleLables();
        
        // 3. 设置底线和滚动的滑块
        setupBottomLineAndScrollLine();
    }
    
    fileprivate func setupTitleLables(){
        // 0.确定label的一些frame的值
        let labelW : CGFloat = frame.width / CGFloat(titles.count);
        let labelH : CGFloat = frame.height - kScrollLineH;
        let labelY : CGFloat = 0;
        
        for (index,title) in titles.enumerated() {
            // 1.创建UILabel
            let label = UILabel();
            
            // 2.设置Label的属性
            label.text = title;
            label.tag = index;
            label.font = UIFont.systemFont(ofSize: 16.0);
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2);
            label.textAlignment = .center;
            
            // 3.设置label的frame
            let labelX : CGFloat = labelW * CGFloat(index);
            label.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH);
            
            // 4.将label添加到scrollView中
            titleScrollView.addSubview(label);
            titleLabels.append(label);
            
            // 5.给label添加手势可以进行交互
            label.isUserInteractionEnabled = true;
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)));
            label.addGestureRecognizer(tapGes);
            
        }
    }
    
    fileprivate func setupBottomLineAndScrollLine(){
        // 1.添加底线
        let bottomLine = UIView();
        bottomLine.backgroundColor = UIColor.lightGray;
        let lineH : CGFloat = 0.5;
        bottomLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH);
        addSubview(bottomLine);
        
        // 2.添加scrollLine
        // 2.1获取第一个label (guard和if else相似，但不同)
        guard let firstLabel = titleLabels.first else{ return };
        
        // 这里通过元组来确定颜色的值
        firstLabel.textColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2);
        
        // 2.2设置添加scrollLine
        titleScrollView.addSubview(scrollLine);
        
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: frame.height - kScrollLineH, width: firstLabel.frame.width, height: kScrollLineH);
    }
}

//MARK:- 监听label的点击
extension YLPageTitleView{
    // 使用事件处理的时候前面要加上@objc
    @objc fileprivate func titleLabelClick(_ tapGes : UITapGestureRecognizer){
        // 0.获取当前Label
        guard let currentLabel = tapGes.view as? UILabel else {return};
        
        // 1.当一个label重复点击的时候直接跳出
        if currentLabel.tag == currentIndex { return }
        
        // 2.获取之前的Label
        let beforeLabel = titleLabels[currentIndex];
        
        // 3.更改label的字体颜色
        currentLabel.textColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2);
        beforeLabel.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2);
        
        // 4.保存最新的label下标值
        currentIndex = currentLabel.tag;
        
        // 5.滚动条位置发生改变
        let scrollLineX = CGFloat(currentIndex) * scrollLine.frame.size.width;
        UIView.animate(withDuration: 0.15, animations: {
            self.scrollLine.frame.origin.x = scrollLineX;
        }) 
        
        // 6.通知代理做事情
        delegate?.pageTitleView(self, selectedIndex: currentIndex);
    }
}

// MARK:- 向外面暴露一个接口(方法)
extension YLPageTitleView {
    func setTitleChangeWithProgress(_ progress:CGFloat,beforeTitleIndex:Int,targetTitleIndex:Int){
        
//        print("progress:\(progress)","beforeTitleIndex:\(beforeTitleIndex)","targetTitleIndex:\(targetTitleIndex)");
        
        // 1.取出beforeTitleIndex/targetTitleIndex
        let beforeLabel = titleLabels[beforeTitleIndex];
        let targetLabel = titleLabels[targetTitleIndex];
        
        // 2.处理滑块的逻辑（根据下面contentView移动的进度，来计算上面label的移动多少）
        let moveTotalX = targetLabel.frame.origin.x - beforeLabel.frame.origin.x;
        let titleMoveX = moveTotalX * progress;
        scrollLine.frame.origin.x = beforeLabel.frame.origin.x + titleMoveX;
        
//      // 3.设置字体颜色变化
//        beforeLabel.textColor = UIColor.grayColor();
//        targetLabel.textColor = UIColor.orangeColor();
        
        // 3.字体颜色的渐变（复杂）  ---  通过元祖用RBG来改变颜色的变化
        // 3.1首先要拿到灰色改变到橙色的范围 也就是橙色的RBG值 减掉 掉灰色的RGB值
        let colorRang = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1,kSelectColor.2 - kNormalColor.2);
        
        // 3.2由橙色变为灰色
        beforeLabel.textColor = UIColor(r: kSelectColor.0 - colorRang.0 * progress, g: kSelectColor.1 - colorRang.1 * progress, b: kSelectColor.2 - colorRang.2 * progress);
        
        // 3.2因为有progress这个值，所以可以计算出颜色改变的多少（改变字体颜色的值）
        targetLabel.textColor = UIColor(r: kNormalColor.0 + colorRang.0 * progress, g: kNormalColor.1 + colorRang.1 * progress, b:  kNormalColor.2 + colorRang.2 * progress);
     
        // 4.将最新的Index赋值给当前的Index(保存最新的currentIndex)
        currentIndex = targetTitleIndex;
    }
}



















