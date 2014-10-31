//
//  ZLMenu.h
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MENU_WIDTH 60
#define MENUHEIHT 40

@interface ZLMenu : NSObject

@property (nonatomic, strong) NSString *normalBackgroundImageName;

@property (nonatomic, strong) NSString *selectedBackgroundImageName;

@property (nonatomic, strong) NSString *title;

@property CGFloat width; //该值只有在所有的menu宽度加起来超过屏幕宽度时才有效

@property CGFloat totalWidth;

/**
 *  menu item初始化方法
 *
 *  @param title                       标题，非空
 *  @param normalBackgroundImageName   默认情况下背景，可以为空使用默认图片
 *  @param selectedBackgroundImageName 选中情况下北京，可以为空使用默认图片
 *  @param width                       期望的宽度，该值只有在所有的menu宽度加起来超过屏幕宽度时才有效
 *
 *  @return
 */
-(id)initWithTitle:(NSString*)title background:(NSString*)normalBackgroundImageName selected:(NSString*)selectedBackgroundImageName desiredWidth:(CGFloat)width;

@end
