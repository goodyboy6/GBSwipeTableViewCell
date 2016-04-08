//
//  GBSwipeCell.h
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/3.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GBStatusClose,
    GBStatusOpen,
} GBStatus;

typedef enum : NSUInteger {
    GBSwipeDirectionToLeft,
    GBSwipeDirectionToRight,
    GBSwipeDirectionToBoth
} GBSwipeDirection;

//UIButton with touch event callback
@interface UIButton (GBBlock)
- (void)addControlEvent:(UIControlEvents)event callBack:(void(^)(UIButton *))callBack;
@end

//Support add swipe to left or/both right
@interface GBSwipeTableViewCell : UITableViewCell

@property (readonly, nonatomic)  GBStatus status NS_AVAILABLE_IOS(7_0);
@property (readonly, nonatomic)  GBSwipeDirection direction NS_AVAILABLE_IOS(7_0);
@property (readwrite, nonatomic)  CGFloat openThreshold NS_AVAILABLE_IOS(7_0);//if valid swiped distance is more than openThreshold, it will open the view or will close animated. Defalultly, if GBSwipeDirectionToLeft or GBSwipeDirectionToRight, the value is the provideView' width; if GBSwipeDirectionToBoth, is the contentView.frame.size.width/3.

/**
 *  swipe to left or right. The method will change cell.selectionStyle and cell.contentView.backgroundColor which should 'opaque', change then after the method called if it unnecessary.
 *
 *  @param handler  the view should provide the valid width when direction is GBSwipeDirectionToLeft or GBSwipeDirectionToRight; view will fill the cell when GBSwipeDirectionToBoth. NOTE: the subview of the view should be autolayouted for dynamic cell height.
 *  @param completion when open status changed, call back.
 */
- (void)addSwipeWithDirection:(GBSwipeDirection)direction provideViewHandler:(UIView *(^)(GBSwipeTableViewCell *))handler statusDidChangedHandler:(void(^)(GBSwipeTableViewCell *cell, UIView *viewThatProvided))completion NS_AVAILABLE_IOS(7_0);
- (void)removeSwipe NS_AVAILABLE_IOS(7_0);//remove the gesture and view added above

//manual action
- (void)openManual NS_AVAILABLE_IOS(2_0);
- (void)closeManual NS_AVAILABLE_IOS(2_0);

@end

@interface GBSwipeTableViewCell (NSDeprecated)

- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion NS_DEPRECATED_IOS(2_0, 7_0);//use addSwipeWithDirection:configure:completion: instead
- (void)removeSwipeLeftGesture NS_DEPRECATED_IOS(2_0, 7_0);//use removeSwipe instead

@end

NS_ASSUME_NONNULL_END


