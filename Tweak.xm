//
//  Tweak.m
//  FLEXing
//
//  Created by Tanner Bennett on 2016-07-11
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//


#import "Interfaces.h"

static BOOL initialized = NO;
static id manager = nil;
static SEL show = nil;

static id (*FLXGetManager)();
static SEL (*FLXRevealSEL)();
static Class (*FLXWindowClass)();

%ctor {
    NSString *standardPath = @"/Library/MobileSubstrate/DynamicLibraries/libFLEX.dylib";
    NSFileManager *disk = NSFileManager.defaultManager;
    void *handle = nil;

    if ([disk fileExistsAtPath:standardPath]) {
        handle = dlopen(standardPath.UTF8String, RTLD_LAZY);
    } else {
        // Load tweak from "alternate" location
        // ...
    }

    if (handle) {
        FLXGetManager = (id(*)())dlsym(handle, "FLXGetManager");
        FLXRevealSEL = (SEL(*)())dlsym(handle, "FLXRevealSEL");
        FLXWindowClass = (Class(*)())dlsym(handle, "FLXWindowClass");

        manager = FLXGetManager();
        show = FLXRevealSEL();
        initialized = YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *standardPath = @"/Library/MobileSubstrate/DynamicLibraries/libFLEX.dylib";
        NSFileManager *disk = NSFileManager.defaultManager;

        if ([disk fileExistsAtPath:standardPath]) {
            void *handle = dlopen(standardPath.UTF8String, RTLD_LAZY);
            if (!handle) {
                Alert(@"Error", @(dlerror() ?: "nil error"));
            }
        }
    });
}

%hook UIWindow
- (BOOL)_shouldCreateContextAsSecure {
    return (initialized && [self isKindOfClass:FLXWindowClass()]) ? YES : %orig;
}

- (id)initWithFrame:(CGRect)frame {
    self = %orig(frame);

    if (initialized) {
        UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show];
        tap.minimumPressDuration = .5;
        tap.numberOfTouchesRequired = 3;

        [self addGestureRecognizer:tap];
    }
    
    return self;
}

%end

%hook UIStatusBarWindow
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    
    if (initialized) {
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show]];
    }
    
    return self;
}
%end

%hook NSObject
%new
+ (NSBundle *)__bundle__ {
    return [NSBundle bundleForClass:self];
}
%end
