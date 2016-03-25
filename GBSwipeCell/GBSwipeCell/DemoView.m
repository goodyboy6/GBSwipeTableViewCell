//
//  BothDemoCell.m
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/25.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import "DemoView.h"

@implementation DemoView

+ (instancetype)viewForDirection:(GBSwipeDirection)direction
{
    NSString *nibName = (direction == GBSwipeDirectionToBoth) ? @"BothDemoView" : @"LeftOrRightDemoView";
    NSArray *array = [[UINib nibWithNibName:nibName bundle:nil] instantiateWithOwner:nil options:nil];
    
    if (!array || array.count == 0) {
        return nil;
    }
    
    return (DemoView *)array[0];
}


- (IBAction)button1Clicked:(id)sender
{
    if (self.button1ClickedHandler) {
        self.button1ClickedHandler();
    }
}

- (IBAction)button2Clicked:(id)sender
{
    if (self.button1ClickedHandler) {
        self.button1ClickedHandler();
    }
}

- (IBAction)button3Clicked:(id)sender
{
    if (self.button1ClickedHandler) {
        self.button1ClickedHandler();
    }
}

- (IBAction)button4Clicked:(id)sender
{
    if (self.button1ClickedHandler) {
        self.button1ClickedHandler();
    }
}

@end
