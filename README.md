# RCLighting

[![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)](https://github.com/RidgeCorn/RCLighting/blob/master/LICENSE)
[![Build Platform](https://cocoapod-badges.herokuapp.com/p/RCLighting/badge.png)](https://github.com/RidgeCorn/RCLighting)
[![Build Version](https://cocoapod-badges.herokuapp.com/v/RCLighting/badge.png)](https://github.com/RidgeCorn/RCLighting)
[![Build Status](https://travis-ci.org/RidgeCorn/RCLighting.png?branch=master)](https://travis-ci.org/RidgeCorn/RCLighting)

Simple lighting (breathing light) effect appears in your view.

<img src="https://github.com/RidgeCorn/RCLighting/raw/master/RCLightingDemo.gif" alt="RCLightingDemo" width="320" height="568" />


**Any idea to make this more awesome? Please feel free to open an issue or make a PR.**



## Requirements
* Xcode 5.0 or higher
* iOS 6.0 or higher
* ARC
* [pop animation library](https://github.com/facebook/pop)



## Run Example

In your terminal,

``` bash
cd [workspace]/RCLighting/RCLightingExample
pod install
```

Then,

``` bash
open RCLightingExample.xcworkspace
```



## Installation


The recommended approach for installating `RCLighting` is via the [CocoaPods](http://cocoapods.org/) package manager.

In your `Podfile`, add a line shows below:

``` bash
pod 'RCLighting'
```

Then,

``` bash
pod update
```



## Usage


### First of all

```objective-c
#import <RCLighting.h>
```


### Show & Remove

Just one line code to show `Lighting`, it's very easy to use.
```objective-c
	[self.view showLighting]; // That's it!
```

Default lighting color is view's background color.

Remove `Lighting` is as simple as above,
```objective-c
	[self.view removeLighting];
```


### Pause & Resume (Debugging)

To pause `Lighting` in view,
```objective-c
	[self.view pauseLighting];
```

To resume `Lighting` in view,
```objective-c
	[self.view resumeLighting];
```

**`[animation setPaused:NO]` is not work on `POPBasicAnimation` if stop `tracer` debug. 
I'm work very hard on it.
Let me know if you see something.**


### State

To get current `Lighting` state in view, 
```objective-c
	[self.view lightingState];
```

Return type is `RCLightingState`.

The value of state would be `RCLightingStateStopped`, `RCLightingStateLighting` and `RCLightingStatePausing`.


### Custom

#### Custom Colors

There are two methods supports custom colors

```objective-c
- (void)showLightingWithColors:(NSArray *)colors; // Lighting With a group of colors.
- (void)showLightingWithColor:(UIColor *)color; // Lighting With one color.
```

And is easy to use,
```objective-c
	[self.view showLightingWithColors:@[[UIColor redColor]]];
```

#### RCLightingLayer

If you want to know more about `Lighting`, the class `RCLightingLayer` is what you wanted. See [RCLighting.h](https://github.com/RidgeCorn/RCLighting/blob/master/RCLighting/RCLighting.h) for more details.

Sample code below shows how to use `RCLightingLayer`,

```objective-c
	RCLightingLayer *lightingLayer = [[RCLightingLayer alloc] initWithColors:@[[UIColor redColor]]]; 
	lightingLayer.perLightingDuration = 2.f;
	lightingLayer.kBackgroundColorAlpha = 1.f;
    [self.view showWithLighting:lightingLayer]; 
```



## License

RCLighting is available under the MIT license. See the [LICENSE](https://github.com/RidgeCorn/RCLighting/blob/master/LICENSE) file for more info.
