//
//  ZLMenu.m
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "ZLMenu.h"

@implementation ZLMenu

-(id)initWithTitle:(NSString*)title background:(NSString*)normalBackgroundImageName selected:(NSString*)selectedBackgroundImageName desiredWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.normalBackgroundImageName = normalBackgroundImageName;
        self.selectedBackgroundImageName = selectedBackgroundImageName;
        self.title = title;
        self.width = width;
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
}

@end
