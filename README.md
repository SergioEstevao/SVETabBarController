# SVETabBarController [![Build Status](https://travis-ci.org/SergioEstevao/SVETabBarController.png?branch=master)](https://travis-ci.org/SergioEstevao/SVETabBarController)

SVETabBarController is a Tab Bar controller inspired by the tab system on Google Chrome for mobile. 
The tabbar is displayed on the top of the screen and it auto hides it or shows it when you scroll inside the selected view.
It was designed to be a drop in replacement of UITabBarController to make the switch easy.


SVETabBarController is tested on iOS 5 and requires ARC. Released under the [MIT license](LICENSE).

## Example

![Screenshot]

Open up the included Xcode project for an example app and the tests.

## Usage

``` objc
    // Initialize the view controller
    SVETabBarController *  tabBarController = [[SVETabBarController alloc] init];
    NSMutableArray * controllers = [NSMutableArray array];
    for ( int i = 0; i < 8; i++) {
        UIViewController * controller = [[SampleTableViewController alloc] init];
        controller.title = [NSString stringWithFormat:@"Tab %i", i];
        [controllers addObject:controller];
    }
    tabBarController.viewControllers = controllers;
```

See the [header](SVETabBarController/SVETabBarController.h) for full documentation.

## Installation

Simply add the files in the `SVETabBarController.h` and `SVETabBarController.m` to your project or add `SVETabBarController` to your Podfile if you're using CocoaPods.
