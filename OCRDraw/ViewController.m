//
//  ViewController.m
//  OCRDraw
//
//  Created by DLZ on 2018/3/27.
//  Copyright © 2018年 DLZ. All rights reserved.
//

#import "ViewController.h"
#import "DTDrawView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet DTDrawView *drawView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _clearButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _clearButton.layer.borderWidth = 1;
    
    
    __weak typeof(self) weakSelf = self;
    _drawView.recognizeBlock = ^(BOOL recognizing, NSString *result) {
        __strong typeof(weakSelf) self = weakSelf;
        if(recognizing){
            [self.activityView startAnimating];
        }else{
            [self.activityView stopAnimating];
            self.resultLabel.text = result;
        }
    };
}

- (IBAction)clearDraw:(id)sender {
    self.resultLabel.text = @"";
    [_drawView clear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
