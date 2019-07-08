//
//  main.m
//  test
//
//  Created by Andries Malan on 2017/07/22.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <AppKit/AppKit.h>
#import "globalState.h"
#import "libKey.h"
#import "timerAlternative.h"
#import "libMouse.h"


void requestAccessibiltyPermission() {
    /*
     NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
     [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
     */
    
    //if (AXIsProcessTrustedWithOptions != NULL) {
    // 10.9 and later
    const void * keys[] = { kAXTrustedCheckOptionPrompt };
    const void * values[] = { kCFBooleanTrue };
    
    CFDictionaryRef options = CFDictionaryCreate(
                                                 kCFAllocatorDefault,
                                                 keys,
                                                 values,
                                                 sizeof(keys) / sizeof(*keys),
                                                 &kCFCopyStringDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
    
    /*return*/ AXIsProcessTrustedWithOptions(options);
    //}
}



int main(int argc, const char * argv[]) {
  
    requestAccessibiltyPermission();
    
    addKeyListenerRunLoop();
    return NSApplicationMain(argc, argv);
}
