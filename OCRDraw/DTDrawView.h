//
//  DTDrawView.h
//  ClassMate
//
//  Created by DLZ on 2018/3/27.
//  Copyright © 2018年 tal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTDrawView : UIView
@property(nonatomic, copy)void (^recognizeBlock)(BOOL recognizing, NSString *result);
//清空
- (void)clear;
@end
