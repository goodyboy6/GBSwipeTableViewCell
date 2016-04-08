//
//  ViewController.m
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/3.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import "ViewController.h"
#import "GBSwipeTableViewCell.h"
#import "DemoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)getRightContainerViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *swipeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 132, 44)];
    swipeView.backgroundColor = [UIColor redColor];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"star" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor blueColor];
    button1.titleLabel.font = [UIFont systemFontOfSize:10];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"say hello" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor purpleColor];
    button2.titleLabel.font = [UIFont systemFontOfSize:10];

    [swipeView addSubview:button1];
    [swipeView addSubview:button2];
    
    //touch events
    __weak typeof(self) weakSelf = self;
    [button1 addControlEvent:UIControlEventTouchUpInside callBack:^(UIButton *b){
        //catch cell
        GBSwipeTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
        [cell closeManual];
        NSLog(@"%@", [b titleForState:UIControlStateNormal]);
    }];
    [button2 addControlEvent:UIControlEventTouchUpInside callBack:^(UIButton *b){
        NSLog(@"do nothing: %@", [b titleForState:UIControlStateNormal]);
    }];
    
    //add constrains
    //.......   masonry or defualt autolayout
    button1.frame = CGRectMake(0, 0, 66, 60);
    button2.frame = CGRectMake(66, 0, 66, 60);
    
    return swipeView;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yyy" forIndexPath:indexPath];
    
    cell.textLabel.text = [[NSDate date] description];
    
    GBSwipeDirection direction = indexPath.row%3;
    [cell addSwipeWithDirection:direction provideViewHandler:^UIView *(GBSwipeTableViewCell *theCell){
        DemoView *demoView = [DemoView viewForDirection:direction];//[self getRightContainerViewAtIndexPath:indexPath];
        
        demoView.button1ClickedHandler = ^{ [theCell closeManual]; };
        demoView.button2ClickedHandler = ^{ [theCell closeManual]; };
        demoView.button3ClickedHandler = ^{ [theCell closeManual]; };
        demoView.button4ClickedHandler = ^{ [theCell closeManual]; };

        return demoView;
        
    } statusDidChangedHandler:^(GBSwipeTableViewCell *cell, UIView *viewThatProvided) {
        switch (cell.status) {
            case GBStatusOpen:{
                
                break;
            }
            case GBStatusClose:{
                
                break;
            }
            default:
                break;
        }
    }];
    
    cell.openThreshold = 30;
    
    return cell;
}



@end
