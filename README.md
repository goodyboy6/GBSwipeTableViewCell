GBSwipeTableViewCell
===========

[![Build Status](https://github.com/goodyboy6/GBSwipeTableViewCell.svg?branch=master)](https://github.com/goodyboy6/GBSwipeTableViewCell)
[![CocoaPods](https://github.com/goodyboy6/GBSwipeTableViewCell.svg)](http://cocoapods.org/?q=GBSwipeTableViewCell)

##Overview

Work needs the cell style Of WeChat, but I did not found a good enough source in github.com. Then i wrote this one.
It only needs the caller provide a view for display when swipe to left or right. That means you have the full control over the view, you can layout all kind subclass of UIView on it,  like UILabel, UIButton, UIImageView, etc.


##Features
* A full control view for display when swipe to left or right.
* Support swipe to left\right\both direction. 
* Supports IOS 7.0+

Example thunmbnail:

![image]()

##Usage

###Available via CocoaPods

Add the following to your Podfile.

pod 'GBSwipeTableViewCell'

Run pod install from your Terminal. This will install the necessary files. 

###Set up the cell

First step is to subclass `GBSwipeTableViewCell.h`. Then you have full control of the views rendered on this cell. 
You can use a xib file or all coding. See detail in demo project.

##Example Project
An example project is provided. It requires IOS7 and can be run on device or simulator. This will work for any device size. 

##Creator
Goodyboy6

##License
GBSwipeTableViewCell is available under the MIT license. See the LICENSE file for more info.

