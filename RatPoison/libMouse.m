//
//  lib.m
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "globalState.h"


void showAlert(NSString * textToShow) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Alert" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:textToShow];
    [alert runModal];
}





//-----------====== Scroll

void scrollRightHorizontalLines(int numberOfLine) {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 2, 0, -numberOfLine);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

void scrollLeftHorizontalLines(int numberOfLine) {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 2, 0, numberOfLine);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

void scrollUpVerticalLines(int numberOfLine) {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 1, -numberOfLine);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

void scrollDownVerticalLines(int numberOfLine) {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitLine, 1, numberOfLine);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}




//-----------==

float getMouseX(void) {
    NSPoint mouseLoc;
    mouseLoc = [NSEvent mouseLocation]; //get current mouse position
    
    return  mouseLoc.x;
}

float getMouseY(void) {
    NSPoint mouseLoc;
    mouseLoc = [NSEvent mouseLocation]; //get current mouse position
    
    
    NSRect e = [[NSScreen mainScreen] frame];
    float screenHeight = e.size.height;
    
    float flippedY = screenHeight - mouseLoc.y;
    
    return flippedY;
}


void clickMouse(void) {
    CGPoint pt;
    pt.x = getMouseX();
    pt.y = getMouseY();
    
    CGPostMouseEvent( pt, 1, 1, 0 );
    CGPostMouseEvent( pt, 1, 1, 1 );
    CGPostMouseEvent( pt, 1, 1, 0 );
}



void mouseLeftButtonDown(void) {
    CGPoint pt;
    pt.x = getMouseX();
    pt.y = getMouseY();
    
    CGPostMouseEvent( pt, 1, 1, 1 );
}


void mouseLeftButtonUp(void) {
    CGPoint pt;
    pt.x = getMouseX();
    pt.y = getMouseY();
    
    CGPostMouseEvent( pt, 1, 1, 0 );
}



void moveMouseTo(CGPoint * pt) {
    /* see https://developer.apple.com/documentation/coregraphics/1456387-cgwarpmousecursorposition?language=objc */
    //CGPostMouseEvent( *pt, 1, 1, 0 );
    CGWarpMouseCursorPosition(*pt);
}


void moveMouse(float dx, float dy) {
    CGPoint pt;
    pt.x = getMouseX()+dx;
    pt.y = getMouseY()+dy;
    
    moveMouseTo(&pt);
}



void moveMouseBasedOnKey(unichar keyThatWasPressed, char keyToCompare,float dx, float dy, int * dIsPressed) {
    
    if (keyThatWasPressed == keyToCompare && *dIsPressed) {
        
        moveMouse(dx,dy);
    }
}




void moveMouseBasedOnDirection(void) {

    char mouseDirection = ' ';

    
    if (*(getScrollKeyIsHeld())) {
        
        char mouseDirection = * (getScrollDirection());
        
        if (mouseDirection == 'h') scrollLeftHorizontalLines(1);
        if (mouseDirection == 'j') scrollUpVerticalLines(1);
        if (mouseDirection == 'k') scrollDownVerticalLines(1);
        if (mouseDirection == 'l') scrollRightHorizontalLines(1);
    }
    else { // else it is mouse move intended
        
        char mouseDirection = * (getMovementDirection());
        
        int mult = 12;
        if ((*(getAccelerateActive()))) mult = 2;
        
        if (mouseDirection == 'h') moveMouse(-1*mult,0);
        if (mouseDirection == 'j') moveMouse(0,1*mult);
        if (mouseDirection == 'k') moveMouse(0,-1*mult);
        if (mouseDirection == 'l') moveMouse(1*mult,0);
    }
}


//-----


//-- NEW



void doDoubleClickAt(float x, float y) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(x, y), kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);

    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 2);

    CGEventSetType(theEvent, kCGEventLeftMouseDown);
    CGEventPost(kCGHIDEventTap, theEvent);

    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);

    CFRelease(theEvent);
}




void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point)
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

/*
void postLeftClick(const CGPoint point)
{
    PostMouseEvent(kCGMouseButtonLeft, kCGEventMouseMoved, point);
    NSLog(@"Click!");
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, point);
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, point);
}


void postRightClick(const CGPoint point)
{
    PostMouseEvent(kCGMouseButtonRight, kCGEventMouseMoved, point);
    NSLog(@"Click Right");
    PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseDown, point);
    PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseUp, point);
}
*/

//---

void postMouseLeftButtonDown(const CGPoint point) {
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, point);
}

void postMouseLeftButtonUp(const CGPoint point) {
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, point);
}


void postMouseMoveEvent(float x, float y) {
    
    CGEventType eventTypeToSend = *(getLeftButton()) ? kCGEventLeftMouseDragged : kCGEventMouseMoved; // if mouse held still, send DRAG event instead of MOVE event.
    PostMouseEvent(kCGMouseButtonLeft, eventTypeToSend, CGPointMake(x, y));
}


void postMouseMoveEventWithRightMouseButton(float x, float y) {
    
    CGEventType eventTypeToSend = kCGEventMouseMoved; // if mouse held still, send DRAG event instead of MOVE event.
    PostMouseEvent(kCGMouseButtonRight, eventTypeToSend, CGPointMake(x, y));
}



//---------------------------------------
float lastMouseX = -100;
float lastMouseY = -100;

void postMouseMoveEventsIfNeeded(void) {
    float newX = getMouseX();
    float newY = getMouseY();
    
    if (lastMouseX != newX || lastMouseY != newY) {
        lastMouseX = newX;
        lastMouseY = newY;
        postMouseMoveEvent(newX, newY);
    }
}


//---


void postMouseLeftButtonDownIfNotPosted() {

    if (!*(getLeftButton())) {
    
        *(getLeftButton()) = 1;
        postMouseMoveEventsIfNeeded();
        postMouseLeftButtonDown(CGPointMake(lastMouseX, lastMouseY));
    }
}


void postMouseLeftButtonUpIfNotPosted() {
    
    if (*(getLeftButton())) {
        
        *(getLeftButton()) = 0;
        postMouseMoveEventsIfNeeded();
        postMouseLeftButtonUp(CGPointMake(lastMouseX, lastMouseY));
    }
}


void postMouseRightButtonPressed() {
    postMouseMoveEventsIfNeeded();
    CGPoint point = CGPointMake(lastMouseX, lastMouseY);
    
    postMouseMoveEventWithRightMouseButton(lastMouseX, lastMouseY);
    PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseDown, point);
    PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseUp, point);
}

