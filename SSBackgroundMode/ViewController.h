//
//  ViewController.h
//  SSBackgroundMode
//
//  Created by mac on 15/11/20.
//  Copyright (c) 2015年 treebear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController


- (void)updateUI;
- (void)backgroudFetch:(void(^)())completion;
@end

