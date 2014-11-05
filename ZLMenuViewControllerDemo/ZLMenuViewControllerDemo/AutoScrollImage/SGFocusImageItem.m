//
//  SGFocusImageItem.m
//  BaseProject
//
//  Created by Shane Gao on 17/6/12.
//  Created by Vincent Tang on 13-7-18.
//  Improved by ZouLinling on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "SGFocusImageItem.h"

@implementation SGFocusImageItem
@synthesize title = _title;
@synthesize image = _image;
@synthesize tag = _tag;

- (id)initWithTitle:(NSString *)title image:(NSString *)image tag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.tag = tag;
    }
    
    return self;
}

- (id)initWithDict:(NSDictionary *)dict tag:(NSInteger)tag
{
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"title"];
            self.image = [dict objectForKey:@"image"];
            //...
        }
    }
    return self;
}
@end
