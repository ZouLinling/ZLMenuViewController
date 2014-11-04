ZLMenuViewController
====================

ZLMenuViewController is a container view controller like TabBarController. It has menus buttons on the top while TabBarController on the bottom.

Thanks Joe Conway, ZLMenuViewController is based on his MenuViewController. Here is the post he wrote to teach us how to write a container view controller. http://stablekernel.com/blog/view-controller-containers-part-i/ 

Thanks 厚脸皮@code4app, ZLHorizontalMenuView is based on his MenuHorizontal. Here is the demo project he wrote: http://code4app.com/ios/53a267b6933bf051468b54b8 

# How to use ZLMenuViewController？

It is much easy to use ZLMenuViewController， only three steps：

1. Init ZLMenuViewController
```objc
//ZLMenuViewController *vc = [[ZLMenuViewController alloc] init];
```
2. Init the ViewControllers which need to add to ZLMenuViewController
```objc
NewsViewController *news1 = [[NewsViewController alloc] initWithNewsType:NewsTypeRoot];
NewsViewController *news2 = [[NewsViewController alloc] initWithNewsType:NewsTypeSports];
NewsViewController *news3 = [[NewsViewController alloc] initWithNewsType:NewsTypeScience];
NewsViewController *news4 = [[NewsViewController alloc] initWithNewsType:NewsTypeMovie];
NewsViewController *news5 = [[NewsViewController alloc] initWithNewsType:NewsTypeGame];
NewsViewController *news6 = [[NewsViewController alloc] initWithNewsType:NewsTypeGame];
news6.menuItem = [[ZLMenu alloc] initWithTitle:@"本地" background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH];
NewsViewController *news7 = [[NewsViewController alloc] initWithNewsType:NewsTypeGame];
news7.menuItem = [[ZLMenu alloc] initWithTitle:@"国际" background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH];
```
Be care, controllers must set menuItem before add to ZLMenuViewController. There are two ways to set menuItem.
1) set when controller initialized, for example:
```objc
news6.menuItem = [[ZLMenu alloc] initWithTitle:@"本地" background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH];
```
2) set in the controller's init method, for example
```objc
-(id)initWithNewsType:(NewsType)newsType
{
    self = [self initWithNibName:@"NewsViewController" bundle:nil];
    ...
    self.menuItem = [[ZLMenu alloc] initWithTitle:title background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH];
    return self;
}
```
3. add initialized controllers to ZLMenuViewController
```objc
[vc setViewControllers:@[news1,news2,news3,news4,news5,news6,news7]];
```
Details please see the demo project.

