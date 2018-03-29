//
//  DTDrawView.m
//  ClassMate
//
//  Created by DLZ on 2018/3/27.
//  Copyright © 2018年 tal. All rights reserved.
//

#import "DTDrawView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <TesseractOCR/TesseractOCR.h>
#pragma clang diagnostic pop

static const CGFloat LineWidth = 8;

@interface DTDrawView ()<G8TesseractDelegate>
@property(nonatomic, strong)NSMutableArray *lines;
@property(nonatomic, strong)UIBezierPath *currentPath;
@property(nonatomic, strong)CAShapeLayer *currentLayer;
@end

@implementation DTDrawView

-(void)startRecognizeDrawWithImage:(UIImage *)image{
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    tesseract.charWhitelist = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    tesseract.image = image;
    tesseract.maximumRecognitionTime = 3.0;
    [tesseract recognize];
    
    NSString *recognizedText = tesseract.recognizedText;
    NSLog(@"-------%@", recognizedText);
    
    if(self.recognizeBlock){
        self.recognizeBlock(NO, recognizedText);
    }
}

- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([event allTouches].count > 1){
        [self.superview touchesMoved:touches withEvent:event];
    }else if ([event allTouches].count == 1) {
        CGPoint startPoint = [self pointWithTouches:touches];
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:startPoint];
        _currentPath = path;
        
        CAShapeLayer *lineLayer = [[self class] createShapeLayerWithPath:path.CGPath];
        [self.layer addSublayer:lineLayer];
        _currentLayer = lineLayer;
        
        [self.lines addObject:lineLayer];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([event allTouches].count > 1){
        [self.superview touchesMoved:touches withEvent:event];
    }else if ([event allTouches].count == 1) {
        CGPoint movePoint = [self pointWithTouches:touches];
        [_currentPath addLineToPoint:movePoint];
        _currentLayer.path = _currentPath.CGPath;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([event allTouches].count > 1){
        [self.superview touchesMoved:touches withEvent:event];
    }else if ([event allTouches].count == 1) {
        
        if(self.recognizeBlock){
            self.recognizeBlock(YES, nil);
        }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage *newImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.9)];

        [self startRecognizeDrawWithImage:newImage];
    }
}

//清空
- (void)clear{
    if (self.lines.count == 0){
        return;
    }
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.lines removeAllObjects];
    
    //清空缓存
    [G8Tesseract clearCache];
}

+(CAShapeLayer *)createShapeLayerWithPath:(CGPathRef)path{
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.backgroundColor = [UIColor clearColor].CGColor;
    lineLayer.path = path;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = [UIColor blackColor].CGColor;
    lineLayer.lineWidth = LineWidth;
    return lineLayer;
}

#pragma mark -get
-(NSMutableArray *)lines{
    if(!_lines){
        _lines = [NSMutableArray new];
    }
    return _lines;
}

#pragma mark - G8TesseractDelegate
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;
}

@end
