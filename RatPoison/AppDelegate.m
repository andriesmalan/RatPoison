//
//  AppDelegate.m
//  test
//
//  Created by Andries Malan on 2017/07/22.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#import "AppDelegate.h"
#import "libMouse.h"




@interface AppDelegate ()

@end

@implementation AppDelegate


/* other methods for running timer body in background
 - (void)targetMethod:(NSTimer *) timer  {
 [self performSelectorInBackground:@selector(doTimerWorkFunction)
 withObject:self];
 }
 
 - (void)targetMethod2:(NSTimer *) timer  {
 dispatch_async(dispatch_get_global_queue(/ *DISPATCH_QUEUE_PRIORITY_DEFAULT QOS_CLASS_BACKGROUND* /DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
 [self  doTimerWorkFunction];
 
 
 //If you then need to execute something making sure it's on the main thread (updating the UI for example)
 dispatch_async(dispatch_get_main_queue(), ^{
 // [self updateGUI]; // example update GUI
 });
 
 });
 }*/





- (void) doTimerWorkFunction_fireMouseEvents {
    
    postMouseMoveEventsIfNeeded();
}





-(void)backgroundRun_fireMouseEvents:(NSTimer *) timer {
    
    NSThread * aThread = [[NSThread alloc] initWithTarget:self selector:@selector(doTimerWorkFunction_fireMouseEvents) object:nil];
    [aThread start];
    
}


- (void) startTimer_fireMouseEvents {
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(backgroundRun_fireMouseEvents:)
                                   userInfo:nil
                                    repeats:YES];
}


//--


- (void) doTimerWorkFunction_updateMousePositionWithoutEvents {

    moveMouseBasedOnDirection();
}





-(void)backgroundRun_updateMousePositionWithoutEvents:(NSTimer *) timer {
    
    NSThread * aThread = [[NSThread alloc] initWithTarget:self selector:@selector(doTimerWorkFunction_updateMousePositionWithoutEvents) object:nil];
    [aThread start];
    
}


- (void) startTimer_updateMousePositionWithoutEvents {
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(backgroundRun_updateMousePositionWithoutEvents:)
                                   userInfo:nil
                                    repeats:YES];
}


//---




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //[label setStringValue:myString];
    
    [self startTimer_updateMousePositionWithoutEvents];
    [self startTimer_fireMouseEvents];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
