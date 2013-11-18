//
//  SVETabBarController.h
//  SVETabBarController
//
//  Created by Sérgio Estêvão on 04/09/2013.
//  Copyright (c) 2013 Sérgio Estêvão. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol SVETabBarControllerDelegate;
/** 
 SVETabBarController is a Tab Bar controller where the tabbar is displayed on the top of the screen and it auto hides it or shows it when you scroll inside the selected view.
 */
@interface SVETabBarController : UIViewController  <UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIViewController * selectedViewController;
@property (nonatomic, assign) BOOL tabBarVisible;
@property (nonatomic, weak) id<SVETabBarControllerDelegate> delegate;

@end

@protocol SVETabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(SVETabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController NS_AVAILABLE_IOS(3_0);
- (void)tabBarController:(SVETabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
@end


@interface UIViewController (SVETabBarController)

-(SVETabBarController*)sve_tabBarController;

@end

