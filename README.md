GBSwipeTableViewCell
===========

[![Build Status](https://github.com/goodyboy6/GBSwipeTableViewCell.svg?branch=master)](https://github.com/goodyboy6/GBSwipeTableViewCell)
[![CocoaPods](https://github.com/goodyboy6/GBSwipeTableViewCell.svg)](http://cocoapods.org/?q=GBSwipeTableViewCell)

##Overview

Work need the cell style Of WeChat. A UITableViewCell subclass that displays customizable left buttons or some other view that are revealed as the user swipes the cell in right direction. The edge-right buttons will pin to the container view and will execute an event similar to how the delete/archive button work in WeChat.

##Features
* Supports adding different kind views on right side of the cell, like UILabel, UIButton, UIImage, etc, in one word, any kind view.
* Offer UIButton extention to support block on kind UIControlEvents when pressed.
* Only support add view to right side of the cell, the left side is on the way. 
* Supports IOS 7+

Example of the buttons revealing as you swipe left:

![image]()

Example of the right most button pinning to the container view:

![image]()

##Usage

###Available via CocoaPods

Add the following to your Podfile.

pod 'GBSwipeTableViewCell'

Run pod install from your Terminal. This will install the necessary files. 

###Set up the cell

First step is to subclass `GBSwipeTableViewCell.h`. You have full control of the views rendered on this cell. You can use a xib file or do this in code. 


###Set up the view 

Next step is to set up the view. all the UIButton, UILabel...is subclass of the View. you will like this:

```objc
- (UIView *)swipeViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *swipeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 132, 44)];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"star" forState:UIControlStateNormal];
    
    [swipeView addSubview:button1];

    __weak typeof(self) weakSelf = self;
    [button1 addControlEvent:UIControlEventTouchUpInside callBack:^(UIButton *b){
        GBSwipeTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
        [cell closeManual];
    }];

    //add all the views that you want
    //add constrains to subviews  ....
    //...
    
    return swipeView;
}
```

###Set up the table view. 

Now you must create your cell instances using the view creation methods above.

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yyy" forIndexPath:indexPath];
    
    [cell addSwipeLeftGestureConfigureHandler:^UIView *{
        return [self swipeViewAtIndexPath:indexPath];//this config whatever view you want to show in the right side
    } completion:^(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status) {
        ...
    }];
    
    return cell;
}
```

##Example Project
An example project is provided. It requires IOS7 and can be run on device or simulator. This will work for any device size. 

##Creator
Goodyboy6

##License
GBSwipeTableViewCell is available under the MIT license. See the LICENSE file for more info.

