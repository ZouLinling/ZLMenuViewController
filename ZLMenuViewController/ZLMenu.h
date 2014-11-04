//
//  ZLMenu.h
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DEFAULT_MENU_WIDTH 60
#define MENUHEIHT 40

@interface ZLMenu : NSObject

@property (nonatomic, strong) NSString *normalBackgroundImageName;

@property (nonatomic, strong) NSString *selectedBackgroundImageName;

@property (nonatomic, strong) NSString *title;

@property CGFloat width; // this value will be effected when totalWidth is wider than SCREEN_WIDTH

@property CGFloat totalWidth;

/**
 *
 *
 *  @param title                       not null
 *  @param normalBackgroundImageName   null to use the default image
 *  @param selectedBackgroundImageName null to use the default image
 *  @param width                       this value will be effected when totalWidth is wider than SCREEN_WIDTH
 *
 *  @return
 */
-(id)initWithTitle:(NSString*)title background:(NSString*)normalBackgroundImageName selected:(NSString*)selectedBackgroundImageName desiredWidth:(CGFloat)width;

@end
