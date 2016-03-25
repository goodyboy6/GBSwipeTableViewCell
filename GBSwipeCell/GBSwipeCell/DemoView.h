//
//  BothDemoCell.h
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/25.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBSwipeTableViewCell.h"

@interface DemoView : UIView

@property (copy, nonatomic) dispatch_block_t button1ClickedHandler;
@property (copy, nonatomic) dispatch_block_t button2ClickedHandler;
@property (copy, nonatomic) dispatch_block_t button3ClickedHandler;
@property (copy, nonatomic) dispatch_block_t button4ClickedHandler;

+ (instancetype)viewForDirection:(GBSwipeDirection)direction;

@end
