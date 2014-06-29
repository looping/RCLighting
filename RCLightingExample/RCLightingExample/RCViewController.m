//
//  RCViewController.m
//  RCLightingExample
//
//  Created by Looping on 14/6/24.
//  Copyright (c) 2014年 RidgeCorn. All rights reserved.
//

#import "RCViewController.h"
#import <RCLighting.h>

@interface RCViewController ()

@property (nonatomic, weak) IBOutlet UIView *effectView;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;

@end

@implementation RCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_effectView showLightingWithColors:@[[UIColor brownColor], [UIColor greenColor], [UIColor cyanColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor magentaColor], [UIColor redColor], [UIColor yellowColor], [UIColor blueColor]]];
    
    [self updateState];
}

- (IBAction)startLighting:(UIButton *)sender {
    RCLightingState state = [_effectView lightingState];
    
    if (state == RCLightingStateStopped) {
        [_effectView showLighting];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [_effectView removeLighting];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }

    [self updateState];
}

- (IBAction)pauseLighting:(UIButton *)sender {
    RCLightingState state = [_effectView lightingState];
    
    [sender setTitle:@"Pause" forState:UIControlStateNormal];

    if (state != RCLightingStateStopped) {
        if (state == RCLightingStateLighting) {
            [_effectView pauseLighting];
            [sender setTitle:@"Resume" forState:UIControlStateNormal];
        } else {
            [_effectView resumeLighting];
        }
    }
        
    [self updateState];
}

- (void)updateState {
    switch ([_effectView lightingState]) {
        case RCLightingStateLighting: {
            [_stateLabel setText:@"Lighting ..."];
        }
            break;
        case RCLightingStatePausing: {
            [_stateLabel setText:@"Pausing ..."];
        }
            break;
        case RCLightingStateStopped: {
            [_stateLabel setText:@"Stopped"];
        }
            break;
            
        default: {
            [_stateLabel setText:@"Unknown state"];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
