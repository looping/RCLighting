//
//  RCLighting.h
//  RCLighting
//
//  Created by Looping on 14-5-25.
//  Copyright (c) 2014  RidgeCorn. All rights reserved.
//

/**
 The MIT License (MIT)
 
 Copyright (c) 2014 RidgeCorn
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <Foundation/Foundation.h>


#pragma mark - RCLightingLayer

typedef NS_ENUM(NSUInteger, RCLightingState) {
    RCLightingStateStopped = 0,
    RCLightingStateLighting,
    RCLightingStatePausing
};

@interface RCLightingLayer : CALayer

@property (nonatomic) NSTimeInterval perLightingDuration; // Default is '1.f'.
@property (nonatomic, readonly) NSArray *colors;
@property (nonatomic, readonly) NSUInteger currentLightingColorIndex;
@property (nonatomic) CGFloat kBackgroundColorAlpha; // Default is '.5f'.


- (instancetype)initWithColors:(NSArray *)colors;

- (instancetype)initWithView:(UIView *)view lightingColors:(NSArray *)colors; // Objects in colors should be 'UIColor' instance.
- (instancetype)initWithView:(UIView *)view; // Default colors would be [UIColor whiteColor] and view.backgroundColor.


- (void)showLighting:(BOOL)restart; // Set 'YES' to lighting colors at index 0, 'NO' for index at currentLightingColorIndex.
- (void)removeLighting;

- (void)pauseLighting;
- (void)resumeLighting;

- (RCLightingState)lightingState;

@end


#pragma mark - RCLighting

@interface UIView (RCLighting)
- (RCLightingLayer *)lighting; // This method would return a RCLightingLayer instance if exises one, otherwise nil.

- (RCLightingState)lightingState;

- (void)showWithLighting:(RCLightingLayer *)lighting;
- (void)showLightingWithColors:(NSArray *)colors;
- (void)showLightingWithColor:(UIColor *)color;
- (void)showLighting;
- (void)removeLighting;

- (void)pauseLighting;
- (void)resumeLighting;


@end
