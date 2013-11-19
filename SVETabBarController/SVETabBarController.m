//
//  SVETabBarController.m
//  SVETabBarController
//
//  Created by Sérgio Estêvão on 04/09/2013.
//  Copyright (c) 2013 Sérgio Estêvão. All rights reserved.
//

#import "SVETabBarController.h"

@implementation UIViewController (SVETabBarController)

-(SVETabBarController*)sve_tabBarController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[SVETabBarController class]]){
            return (SVETabBarController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

@end

@interface SVETabBarController ()  {

}
@property (strong, nonatomic) UIView *container;
@end

@implementation SVETabBarController {

}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil) return nil;
    _tabBarVisible = YES;
    return self;
}

- (void) awakeFromNib {

    _tabBarVisible = YES;
}

- (void) dealloc {
    if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
        UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
        [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    CGRect frame = CGRectMake(0,0,self.view.frame.size.width,49);
    self.tabBar = [[UITabBar alloc] initWithFrame:frame];
    self.tabBar.delegate = self;
    [self.tabBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
    
    self.container = [[UIView alloc] initWithFrame:self.view.bounds];
    self.container.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.container];
    [self.container setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    
    [self.view addSubview:self.tabBar];
    //[self showTabBar];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setViewControllers:_viewControllers];
    [self setSelectedIndex:_selectedIndex];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat top = 0;
    if ( [self respondsToSelector:@selector(topLayoutGuide)]){
        id<UILayoutSupport> topSize = [self topLayoutGuide];
        top = [topSize length];
    }
    
    CGRect frame = CGRectMake(0,top,self.view.frame.size.width,49);
    self.tabBar.frame = frame;
    
    frame = self.view.bounds;
    frame.origin.y = top;
    frame.size.height -= top;
    self.container.frame = frame;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void) setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    _viewControllers = [NSArray arrayWithArray:viewControllers];
    
    NSMutableArray * tabBaritems = [NSMutableArray array];
    int index = 0;
    for (UIViewController *viewController in _viewControllers) {
        UITabBarItem *tab = viewController.tabBarItem;
        if (tab == nil){
            tab = [[UITabBarItem alloc] initWithTitle:[NSString stringWithFormat:@"%i",index] image:nil tag:index];
        }
        tab.tag = index;
        [tabBaritems addObject:tab];
        index++;
    }
    
    [self.tabBar setItems:tabBaritems animated:animated];
    self.tabBar.selectedItem = tabBaritems[0];
    [self tabBar:self.tabBar didSelectItem:tabBaritems[0]];
}

- (void) setSelectedViewController:(UIViewController *)selectedViewController {
    
    NSUInteger index = [_viewControllers indexOfObject:selectedViewController];
    
    NSAssert(index != NSNotFound, @"Only a view controller in the tab bar controller's list of view controllers can be selected.");
    
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]){
        if (![_delegate tabBarController:self shouldSelectViewController:selectedViewController]) {
            return;
        }
            
    }
    
    // Remove old view if exists
    if (_selectedViewController != nil) {
        [_selectedViewController willMoveToParentViewController:nil];
        [[_selectedViewController view] removeFromSuperview];
        [_selectedViewController removeFromParentViewController];
        if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
            UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
            [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        }
    }
    
    // Add new view
    _selectedViewController = selectedViewController;
    [self addChildViewController:_selectedViewController];
    [self.container addSubview:[_selectedViewController view]];
    _selectedViewController.view.frame = self.container.bounds;
    [_selectedViewController didMoveToParentViewController:self];
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]){
        [_delegate tabBarController:self didSelectViewController:selectedViewController];
    }
    //Configure Auto hide and show if content view is UIScrollView
    if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
        UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
        [scrollView.panGestureRecognizer addTarget:self action:@selector(handleGesture:)];
        _tabBarVisible = YES;
        scrollView.contentInset = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    
    _selectedIndex = index;
    [self.tabBar setSelectedItem:self.tabBar.items[index]];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) return;
    
    CGFloat top = 0;
    if ( [self respondsToSelector:@selector(topLayoutGuide)]){
        id<UILayoutSupport> topSize = [self topLayoutGuide];
        top = [topSize length];
    }
    CGRect frame = self.tabBar.frame;
    if (frame.origin.y < self.container.frame.origin.y-((frame.size.height)/2)){
        [self hideTabBar];
    } else {
        [self showTabBar];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldOffset = [[change valueForKey:NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if ( newOffset.y < 0){
            return;
        }
        CGSize size = [object contentSize];
        if (newOffset.y > (size.height - [object frame].size.height)){
            return;
        }
        
        if ((newOffset.y - oldOffset.y) < 0) {
            [self showTabBar:(newOffset.y - oldOffset.y)];
        }
        if ((newOffset.y - oldOffset.y) > 0 ) {
            [self hideTabBar:(newOffset.y - oldOffset.y)];
        }
    }
    
    
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex {
    NSAssert(selectedIndex >= 0, @"Index must be in range");
    NSAssert(selectedIndex < _viewControllers.count, @"Index must be in range");
    
    [self setSelectedViewController:_viewControllers[selectedIndex]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {    
    UIViewController * selected = [self.viewControllers objectAtIndex:item.tag];
    [self setSelectedViewController:selected];
}

- (void) setTabBarVisible:(BOOL)tabBarVisible {
    if (_tabBarVisible == tabBarVisible) return;
    
    if (tabBarVisible){
        [self showTabBar];
    } else {
        [self hideTabBar];
    }
}

- (void)hideTabBar:(CGFloat)offset {
    if (!_tabBarVisible) return;
    
    CGFloat top = 0;
    if ( [self respondsToSelector:@selector(topLayoutGuide)]){
        id<UILayoutSupport> topSize = [self topLayoutGuide];
        top = [topSize length];
    }
    CGRect frame = self.tabBar.frame;
    frame.origin.y -= offset;
    if (frame.origin.y >= self.container.frame.origin.y-frame.size.height-top){
        self.tabBar.frame = frame;
        return;
    }
    frame.origin.y = self.container.frame.origin.y-frame.size.height-top;
    self.tabBar.frame = frame;
    _tabBarVisible = NO;
    if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
        UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
}

- (void)showTabBar:(CGFloat)offset {
    if (_tabBarVisible) return;
    
    CGRect frame = self.tabBar.frame;
    frame.origin.y += (-offset);
    if (frame.origin.y <= self.container.frame.origin.y){
        self.tabBar.frame = frame;
        return;
    }
    frame.origin.y = self.container.frame.origin.y;
    self.tabBar.frame = frame;
    _tabBarVisible = YES;
    if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
        UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
        scrollView.contentInset = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
    }
}

- (void)hideTabBar {
    [UIView animateWithDuration:0.1 animations:^{
        CGFloat top = 0;
        if ( [self respondsToSelector:@selector(topLayoutGuide)]){
            id<UILayoutSupport> topSize = [self topLayoutGuide];
            top = [topSize length];
        }
        CGRect frame = self.tabBar.frame;
        frame.origin.y = self.container.frame.origin.y-frame.size.height-top;
        self.tabBar.frame = frame;
        
        if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
            UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
            scrollView.contentInset = UIEdgeInsetsZero;
            scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
        }
    } completion:^(BOOL finished) {
        _tabBarVisible = NO;
    }];
}


- (void)showTabBar {
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame = self.tabBar.frame;
        frame.origin.y = self.container.frame.origin.y;
        self.tabBar.frame = frame;
        if ([_selectedViewController.view isKindOfClass:[UIScrollView class]]){
            UIScrollView * scrollView = (UIScrollView *)_selectedViewController.view;
            scrollView.contentInset = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
            scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tabBar.frame.size.height, 0, 0, 0);
        }
    }completion:^(BOOL finished) {
        _tabBarVisible = YES;
    }];
}

- (void)swipeLeft {
    NSInteger index = ( (self.selectedIndex == _viewControllers.count-1) ? 0 : self.selectedIndex+1) ;
    [self setSelectedIndex:index];
}

- (void)swipeRight {
    NSInteger index = ( (self.selectedIndex == 0) ? _viewControllers.count-1 : self.selectedIndex-1) ;
    [self setSelectedIndex:index];
}

@end
