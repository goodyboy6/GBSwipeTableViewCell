GBSwipeTableViewCell
===========

Work needs the cell style Of WeChat, but I did not found a good enough source in github.com. Then i wrote this one.
It only needs the caller provide a view for display when swipe to left or right. That means you have the full control over the view, you can layout all kind subclass of UIView on it,  like UILabel, UIButton, UIImageView, etc.

##Features
* A full control view for display when swipe to left or right.
* Support swipe to left\right\both direction. 
* Supports IOS 7.0+

Example thunmbnail:

![image](https://github.com/goodyboy6/GBSwipeTableViewCell/blob/master/snatshot.png)

##Usage

###Install
pod 'GBSwipeTableViewCell'

###Set up the cell

First step is to subclass `GBSwipeTableViewCell.h`. Then you have full control of the views rendered on this cell. 
You can use a xib file or all coding. See detail in demo project.
```objective-c
if (indexPath.section == 1 && [model hasContact]) {
    __weak typeof(self) weakSelf = self;
    [cell addSwipeWithDirection:GBSwipeDirectionToLeft provideViewHandler:^UIView * _Nonnull(GBSwipeTableViewCell * _Nonnull c) {
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 setTitle:[NSString stringWithFormat:NSLocalizedStringSearch(@"search.result.contact.ower", @"联系%@"), model.ownerName] forState:UIControlStateNormal];
        button1.backgroundColor = kDefalutStyleTintColor;
        button1.width = 100;
        
        button1.titleLabel.font = [UIFont systemFontOfSize:13];
        button1.titleLabel.adjustsFontSizeToFitWidth = YES;
        button1.titleLabel.minimumScaleFactor = 0.8;
        
        [button1 addControlEvent:UIControlEventTouchUpInside callBack:^(UIButton * _Nonnull b) {
            if ([model hasContact]) {
                [WBPhoneCallManager callPhoneInArray:@[model.ownerMobile] inView:weakSelf.view editHandler:NULL];
            }
        }];
        return button1;
    } statusDidChangedHandler:^(GBSwipeTableViewCell * _Nonnull cell, UIView * _Nonnull viewThatProvided) { }];
}else{
    [cell removeSwipe];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
}
```
##Example Project
An example project is provided. It requires IOS7 and can be run on device or simulator. This will work for any device size. 

##Creator
Goodyboy6

##License
GBSwipeTableViewCell is available under the MIT license. See the LICENSE file for more info.

