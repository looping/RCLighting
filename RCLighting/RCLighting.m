//
//  RCLighting.m
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

#import "RCLighting.h"
#import <POP/POP.h>


#pragma mark - RCLightingLayer

#define RCDefaultLightingDuration 1.f
#define RCLightingBGColorAlpha .5f
#define RCLightingShadowRadius 5.f
#define RCLightingShadowOpacity .9f
#define RCLightingMiniDuration .02f

#define RCDefaultLightingColor [UIColor whiteColor]


#ifdef DEBUG
static inline NSTimeInterval newDuration(NSTimeInterval duration, NSTimeInterval time) {
    CGFloat leftTime = duration - time;
    return ((leftTime > RCLightingMiniDuration) ? ((leftTime < duration) ? leftTime : (duration - RCLightingMiniDuration)) : RCLightingMiniDuration);
}
#endif

static NSArray * verifiedColors(NSArray *colors, UIColor *replaceColor) {
    NSMutableArray *verifiedColors = [@[] mutableCopy];
    UIColor *defaultColor = RCDefaultLightingColor;
    
    if ( !colors) {
        [verifiedColors addObjectsFromArray: @[defaultColor, replaceColor]]; // Default colors.
    } else {
        for (id color in colors) {
            if ([color isKindOfClass:[UIColor class]]) {
                [verifiedColors addObject:color];
            } else {
                [verifiedColors addObject:replaceColor]; // Replace invalid color.
            }
        }

        if ([verifiedColors count] == 1) { // We need two colors in this lighting effect.
            [verifiedColors insertObject:defaultColor atIndex:0];
        }
    }
    
    return verifiedColors;
}

static NSString *const kRCSDColorAnimation = @"RCLightingSDColorAnimationKey";
static NSString *const kRCBGColorAnimation = @"RCLightingBGColorAnimationKey";

static NSString *const kColorAnimationFrom = @"FromColor";
static NSString *const kColorAnimationTo = @"ToColor";

@interface RCLightingLayer ()

@property (nonatomic) NSTimer *lightingTimer;
@property (nonatomic) BOOL lighting;
@property (nonatomic) BOOL stopped;

@end

@implementation RCLightingLayer


#pragma mark - (RCLightingLayer) Initialization

- (instancetype)initWithColors:(NSArray *)colors {
    if (self = [super init]) {
        [self setBackgroundColor:RCDefaultLightingColor.CGColor];
        [self setShadowOffset:CGSizeZero];
        [self setShadowRadius:RCLightingShadowRadius];
        [self setShadowOpacity:RCLightingShadowOpacity];
        
        _kBackgroundColorAlpha = RCLightingBGColorAlpha;
        _currentLightingColorIndex = 0;
        _colors = verifiedColors(colors, RCDefaultLightingColor);
        
        _perLightingDuration = RCDefaultLightingDuration;
        
        _stopped = YES;
        _lighting = NO;
    }
    
    return self;
}

- (instancetype)initWithView:(UIView *)view lightingColors:(NSArray *)colors {
    RCLightingLayer *layer = [self initWithColors:colors];
    
    if (layer) {
        [layer showInView:view];
    }
    
    return layer;
}

- (instancetype)initWithView:(UIView *)view {
    return [self initWithView:view lightingColors:@[view.backgroundColor ?: RCDefaultLightingColor]];
}

- (void)showInView:(UIView *)view {
    CGRect frame = view.frame;
    frame.origin = CGPointZero;
    [self setFrame:frame];
    
    [view removeLighting]; // Remove lighting if exists one.
    [view.layer insertSublayer:self atIndex:0]; // Send lighting layer to back.
    
    [self showLighting:YES];
}


#pragma mark - (RCLightingLayer) Properties

- (void)setPerLightingDuration:(NSTimeInterval)duration {
    _perLightingDuration = duration > RCLightingMiniDuration ? duration : RCLightingMiniDuration;

    if (_lighting) {
        [self pauseLighting];
        [self performSelector:@selector(resumeLighting) withObject:nil afterDelay:RCLightingMiniDuration];
    }
}


#pragma mark - (RCLightingLayer) Lighting management

- (void)showLighting:(BOOL)restart {
    if (_lightingTimer) {
        [self _stopLighting];
    }
    
    [self setHidden:NO];
    
    if (restart) {
        _currentLightingColorIndex = 0;
    }
    
    [self _startTimer];
    
    [_lightingTimer fire];
}

- (void)pauseLighting {
    [self _stopTimer];
    
    [self _pauseLightingAnimation:YES];
}

- (void)resumeLighting {
    if ( !_stopped && !_lighting) {
        [self _pauseLightingAnimation:NO];
    }
}

- (RCLightingState)lightingState {
    RCLightingState _state = RCLightingStateStopped;
    
    if ( !_stopped) {
        if (_lighting) {
            _state = RCLightingStateLighting;
        } else {
            _state = RCLightingStatePausing;
        }
    }
    
    return _state;
}

- (void)removeLighting {
    if ( !_stopped) {
        [self _stopLighting];
    }
    
    [self pop_removeAllAnimations];
    
    [self removeFromSuperlayer];
}


#pragma mark - (RCLightingLayer) Internal
#pragma mark Show Lighting Animation

- (void)_showLightingAtIndex:(NSUInteger)index {
    _lighting = YES;
    _currentLightingColorIndex = ++_currentLightingColorIndex % [_colors count];

    [self _startColorAnimationAtIndex:index withKey:kPOPLayerBackgroundColor];

    [self _startColorAnimationAtIndex:index withKey: kPOPLayerShadowColor];
}

- (void)_startColorAnimationAtIndex:(NSUInteger)index withKey:(NSString *)animationKey {
    [self _showAnimationWithColor:[self _genAnimationColorsFromIndex:index withAnimationKey:animationKey] andKey:animationKey];
}

- (NSDictionary *)_genAnimationColorsFromIndex:(NSUInteger)index withAnimationKey:(NSString *)animationKey {
    NSMutableDictionary *animationColors = [@{} mutableCopy];
    UIColor *fromColor, *toColor;
    
    if ([animationKey isEqualToString:kPOPLayerShadowColor]) {
        fromColor = [_colors objectAtIndex:index];
        
        toColor = [_colors objectAtIndex:_currentLightingColorIndex];
    } else if ([animationKey isEqualToString:kPOPLayerBackgroundColor]){
        fromColor = [[_colors objectAtIndex:index] colorWithAlphaComponent:_kBackgroundColorAlpha];
        
        toColor = [[_colors objectAtIndex:_currentLightingColorIndex] colorWithAlphaComponent:_kBackgroundColorAlpha];;
    }
    
    [animationColors setObject:fromColor forKey:kColorAnimationFrom];
    [animationColors setObject:toColor forKey:kColorAnimationTo];
    
    return animationColors;
}

- (void)_showAnimationWithColor:(NSDictionary *)colors andKey:(NSString *)animationKey {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:animationKey];
    [animation setPaused:NO];
    animation.duration = _perLightingDuration;
    animation.fromValue = [colors objectForKey:kColorAnimationFrom];
    animation.toValue =  [colors objectForKey:kColorAnimationTo];
    
    [self pop_addAnimation:animation forKey:animationKey];
   
#ifdef DEBUG
    [animation.tracer start];
#endif
    
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if ([animationKey isEqualToString:kPOPLayerShadowColor] && !_lightingTimer && _lighting) { // For resume lighting timer after paused.
            [self showLighting:NO];
        }
    }];
}


#pragma mark Pause Lighting Animation

- (void)_pauseLightingAnimation:(BOOL)pause {
    _lighting = !pause;
    
    for (NSString *animationKey in [self pop_animationKeys]) {
        POPBasicAnimation *animation = [self pop_animationForKey:animationKey];
        
#ifdef DEBUG
        if ( !pause) { // Resume animation value.
            POPAnimationValueEvent *event = [[animation.tracer eventsWithType:kPOPAnimationEventPropertyWrite] lastObject];
            
            animation.fromValue = event.value;
            
            animation.duration = newDuration(animation.duration, event.time);
        }
#endif
        
        [animation setPaused:pause];
    }
}

#pragma mark Start Lighting Animation

- (void)_startLighting {
    _stopped = NO;
    
    [self _showLightingAtIndex:_currentLightingColorIndex];
}

#pragma mark Stop Lighting

- (void)_stopLighting {
    _stopped = YES;
    
    [self pauseLighting];
}

#pragma mark Start Lighting Timer

- (void)_startTimer {
    _lighting = YES;
    [self _stopTimer];

    _lightingTimer = [NSTimer scheduledTimerWithTimeInterval:_perLightingDuration target:self selector:@selector(_startLighting) userInfo:nil repeats:YES];
}

#pragma mark Stop Lighting Timer

- (void)_stopTimer {
    _lighting = NO;
    
    [_lightingTimer invalidate];
    _lightingTimer = nil;
}

@end


#pragma mark - RCLighting

@implementation UIView (RCLighting)


#pragma mark - (RCLighting) Lighting management

#pragma mark Lighting Instance

- (RCLightingLayer *)lighting {
    return [self _lightingLayer];
}

#pragma mark Lighting State

- (RCLightingState)lightingState {
    return [[self lighting] lightingState];
}

#pragma mark Show Lighting

- (void)showWithLighting:(RCLightingLayer *)lighting {
    [lighting showInView:self];
}

- (void)showLightingWithColors:(NSArray *)colors duration:(NSTimeInterval)duration {
    RCLightingLayer *layer = [[RCLightingLayer alloc] initWithView:self lightingColors:colors];

    layer.perLightingDuration = duration;
    
    [layer showLighting:YES];
}

- (void)showLightingWithColors:(NSArray *)colors {
    [self showLightingWithColors:colors duration:RCDefaultLightingDuration];
}

- (void)showLightingWithColor:(UIColor *)color duration:(NSTimeInterval)duration {
    [self showLightingWithColors:@[RCDefaultLightingColor, color] duration:duration];
}

- (void)showLightingWithColor:(UIColor *)color {
    [self showLightingWithColors:@[RCDefaultLightingColor, color]];
}

- (void)showLightingWithDuration:(NSTimeInterval)duration {
    [self showLightingWithColor:self.backgroundColor ?: RCDefaultLightingColor duration:duration];
}

- (void)showLighting {
    [self showLightingWithColor:self.backgroundColor ?: RCDefaultLightingColor];
}

#pragma mark Pause Lighting

- (void)pauseLighting {
    [[self lighting] pauseLighting];
}

#pragma mark Resume Lighting

- (void)resumeLighting {
    [[self lighting] resumeLighting];
}

#pragma mark Remove Lighting

- (void)removeLighting {
    [[self lighting] removeLighting];
}


#pragma mark - (RCLighting) Internal
#pragma mark Lighting Instance 

- (RCLightingLayer *)_lightingLayer {
    RCLightingLayer *retLayer = nil;
    
    for (id layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[RCLightingLayer class]]) {
            retLayer = layer;
            break;
        }
    }
    
    return retLayer;
}

@end
