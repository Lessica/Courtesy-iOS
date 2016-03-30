# MiniDateView

[![CI Status](http://img.shields.io/travis/i_82/MiniDateView.svg?style=flat)](https://travis-ci.org/i_82/MiniDateView)
[![Version](https://img.shields.io/cocoapods/v/MiniDateView.svg?style=flat)](http://cocoapods.org/pods/MiniDateView)
[![License](https://img.shields.io/cocoapods/l/MiniDateView.svg?style=flat)](http://cocoapods.org/pods/MiniDateView)
[![Platform](https://img.shields.io/cocoapods/p/MiniDateView.svg?style=flat)](http://cocoapods.org/pods/MiniDateView)

A simple Chinese style mini date view.

## Screenshot

[![Preview](https://raw.githubusercontent.com/Lessica/MiniDateView/master/QQ20160330-0%402x.png)](https://raw.githubusercontent.com/Lessica/MiniDateView/master/QQ20160330-0%402x.png)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Create
```Objective-C
  // Its width and height cannot be adjusted.
  MiniDateView *dateView = [[MiniDateView alloc] initWithFrame:CGRectMake(100, 100, 0, 0)];
  dateView.tintColor = [UIColor grayColor];
  self.dateView = dateView;
  [self.view addSubview:dateView];
```

### Redraw
```Objective-C
  // Refresh date
  self.dateView.date = [[NSDate date] dateByAddingTimeInterval:86400];
  [self.dateView setNeedsDisplay];
```

## Requirements

- iOS SDK 9.0+
- Xcode
- Cocoapods
- This spec needs ARC.

## Installation

MiniDateView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MiniDateView"
```

## Author

i_82, i.82@qq.com

## License

MiniDateView is available under the MIT license. See the LICENSE file for more info.
