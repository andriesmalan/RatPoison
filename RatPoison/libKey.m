//
//  libKey.m
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//


/* TO-DO
 
    -> If another click key is detected within a short time from previous one, send double click for the 2nd click
    -> Make it a Status Bar App
    -> D + R to restart the app
 
 */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "libMouse.h"
#import "globalState.h"


unichar getKeyboardCharFromEvent(NSEvent *event) {
    NSString *chars = [[event characters] lowercaseString];
    unichar character = [chars characterAtIndex:0];
    return character;
}


/*
  example of modifier keys - http://techqa.info/programming/question/35871788/capture-global-keydown-events-(not-simply-observe)
 
    may consider using DDHotKEY library instead:
 https://github.com/davedelong/DDHotKey 
  or using the same principles
 
    it uses InstallApplicationEventHandler
 
 https://stackoverflow.com/questions/1603030/how-to-monitor-global-modifier-key-state-in-any-application
 
 but you should actually use
 
 InstallEventHandler and pass to it GetEventMonitorTarget()
 
 
 CGEventTaps is the newer recommended way
 
  https://developer.apple.com/documentation/coregraphics/quartz_event_services
    tapPostEvent / post - could be used to selectively send the event on
 
    tapCreate - https://developer.apple.com/documentation/coregraphics/cgevent/1454426-tapcreate
 
 
        alternative: CGEventTapCreate
 
 
  very simple example of swapping one keypress for another
        http://osxbook.com/book/bonus/chapter2/alterkeys/         further explnation at https://github.com/sdegutis/mjolnir/issues/9
 
 
        for all keycodes - http://www.jacobward.co.uk/cgkeycode-list-objective-c/
 
        for 'special mac keys' http://macbiblioblog.blogspot.co.za/2014/12/key-codes-for-function-and-special-keys.html
 
 
 
 
 */



void changeKeyInEvent(CGKeyCode newKeyCode, CGEventRef event) {
    CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, (int64_t)newKeyCode);
}


void sendKey(CGEventTapProxy proxy, CGKeyCode keyToSend) {
    CGEventRef keyEventDown = CGEventCreateKeyboardEvent( NULL, 1, true);
    CGEventRef keyEventUp   = CGEventCreateKeyboardEvent(NULL, 1, false);
    
    CGEventSetIntegerValueField(keyEventDown,kCGKeyboardEventKeycode, keyToSend);
    CGEventSetIntegerValueField(keyEventUp,  kCGKeyboardEventKeycode, keyToSend);
    
    CGEventTapPostEvent(proxy, keyEventDown);
    CGEventTapPostEvent(proxy, keyEventUp);
    
    CFRelease(keyEventDown);
    CFRelease(keyEventUp);
}


void sendKeyDownOnly(CGEventTapProxy proxy, CGKeyCode keyToSend) {
    CGEventRef keyEventDown = CGEventCreateKeyboardEvent( NULL, 1, true);
    CGEventSetIntegerValueField(keyEventDown,kCGKeyboardEventKeycode, keyToSend);
    CGEventTapPostEvent(proxy, keyEventDown);
    CFRelease(keyEventDown);
}


void sendKeyUpOnly(CGEventTapProxy proxy, CGKeyCode keyToSend) {
    CGEventRef keyEventUp   = CGEventCreateKeyboardEvent(NULL, 1, false);
    CGEventSetIntegerValueField(keyEventUp,  kCGKeyboardEventKeycode, keyToSend);
    CGEventTapPostEvent(proxy, keyEventUp);
    CFRelease(keyEventUp);
}


void sendCMDClick(CGEventTapProxy proxy) {
    sendKeyDownOnly(proxy, 55); // CMD-Key down
    postMouseLeftButtonDownIfNotPosted();
    postMouseLeftButtonUpIfNotPosted();
    sendKeyUpOnly(proxy, 55);   // CMD-Key up
    
}


unichar unicharFromKey(NSEvent *event) {
    unichar character = getKeyboardCharFromEvent(event);
    return character;
}


char isDirectionKey(CGKeyCode keycode) {
    switch (keycode) {
        case 0x04 : //H-Key
            return 'h'; // supress the H key-down
        case 0x26 : //J-Key
            return 'j'; // supress the H key-down
        case 0x28 : //K-Key
            return 'k'; // supress the H key-down
        case 0x25 : //L-Key
            return 'l'; // supress the H key-down
    }
    return 0;
}


unichar               keyStatus         [77];
CGEventRef            keyLastDownEvent  [77];
CGEventRef            keyLastUpEvent    [77];
CGEventRef            mostRecentKeyDownEvent;
UInt16                mostRecentKeyDownCode;


void updateKeyUp(CGEventRef event) {
    if (!event) return;
    
    CGKeyCode keycode        = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    UInt16    keyInt         = (UInt16) keycode;
    
    keyStatus[keyInt]        = 'u';
    keyLastUpEvent[keyInt]   = event;
}


void updateKeyDown(CGEventRef event) {
    if (!event) return;
    
    CGKeyCode keycode        = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    UInt16    keyInt         = (UInt16) keycode;
    
    keyStatus[keyInt]        = 'd';
    keyLastDownEvent[keyInt] = event;
    
    mostRecentKeyDownEvent   = event;
    mostRecentKeyDownCode    = keycode;
}


//---

void resetAllKeyboardAndMouseState() {
    postMouseLeftButtonUpIfNotPosted();  // Release any mouse buttons held during this session
    *(getWasHotKeyPressedWithD())   = 0;
    *(getWasOtherKeyPressedWithD()) = 0;
    *(getScrollKeyIsHeld())         = 0;
    *(getDIsPressed())              = 0;
    *(getAccelerateActive())        = 0;
    *(getMovementDirection())       = 0;
    *(getLeftButton())              = 0;
}

//---


CGEventRef handleKeyDown(CGEventRef event, CGEventTapProxy proxy) {
    
    updateKeyDown(event);
    CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
    //D-Key
    if (keycode == 0x02) {
        resetAllKeyboardAndMouseState();
        *(getDIsPressed())              = 1;

        return nil; //swallow the key-press event for the D, unless it is released again, without any of the modifier keys having been pressed during the same interval we will keep it swallowed, but if it is later released, we will then manually recreate it.
    }
    else
        
    if (*(getDIsPressed())) { // D-Key is held down, while other keys are pressed
        
        if (isDirectionKey(keycode)) {
            
            if (*getScrollKeyIsHeld()) {
                *(getScrollDirection())        = isDirectionKey(keycode);
            }
            else {
                *(getMovementDirection())      = isDirectionKey(keycode);
            }
            
            *(getWasHotKeyPressedWithD())  =  1;
            return nil; // suppress H,J,K,dL
        }
        else
        
        if (keycode == 0x09) { // V-Key down triggered
            
            *(getWasHotKeyPressedWithD())    = 1;
            
            postMouseLeftButtonDownIfNotPosted();
            
            return nil; // suppress V
        }
        else

        if (keycode == 11) { // B-Key down triggered
            
            *(getWasHotKeyPressedWithD())    = 1;
            
            sendCMDClick(proxy);
            
            return nil; // suppress V
        }
        else
            
        if (keycode == 45) { // N-Key down triggered
            
            *(getWasHotKeyPressedWithD())    = 1;
            
            postMouseRightButtonPressed();
            
            return nil; // suppress V
        }
        else
            
        if (keycode == 0x03) { // F-Key down triggered
            
            *(getWasHotKeyPressedWithD())    = 1;
            
            //toggle acceleration
            if (!*(getAccelerateActive()))
                *(getAccelerateActive())         = 1;
            else
                *(getAccelerateActive())         = 0;
            
            return nil; // suppress F
        }
        else

        if (keycode == 0x01) { // S-Key down triggered
            
            *(getWasHotKeyPressedWithD())    = 1;
            *(getScrollKeyIsHeld())          = 1;
            
            
            return nil; // suppress S
        }

        
        else {
            //If any other K that we don't care about was pressed, while D was being held, we need to rejuggle the key events, to ensure that the keys come out in the order that they were pressed down, not in the order that they were released. - handles corner case when typing  D followed by E rapidly it causes incorrect key ordering. (because we previously swallowed the D-Down event for later release)
            
                
            if (*(getWasHotKeyPressedWithD())) { // however: if a hotkey sequence was triggered while D was still held, but before this non-active key was pressed, then we simply swallow this key, and skip the special key-event-reconstruction stuff
                return nil;
                
            }
            
            //Some other key was pressed, whilst D was held, so deactivate our keyboard take-over, and try to spit out events in the order they would have come out if we didn't interfere.
            
            resetAllKeyboardAndMouseState();
            
            sendKeyDownOnly(proxy, 0x02);    // D-key
            sendKeyDownOnly(proxy, keycode); // whatever other key was pressed
            *(getDIsPressed())              = 1; // D-key is still held
            *(getWasOtherKeyPressedWithD()) = 1; // Other key is still held
            
            // one problem with this logic - the original key release events when the user actually lifts his fingers, will still fire, so there will be more key-up events from these two keys that there were down events..... a better solution may be required.
            
            return nil;
            
            
        }
        
    }
    
    return event;
}





CGEventRef handleKeyUp(CGEventRef event, CGEventTapProxy proxy) {
    
    updateKeyUp(event);
    CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
    if (keycode == 0x02) { //D-key
        
        int wasAnyHotKeyPressedWithD    = *(getWasHotKeyPressedWithD());   // grab it before we reset state
        int wasOtherKeyPressedWithD     = *(getWasOtherKeyPressedWithD()); // grab it before we reset state
        
        resetAllKeyboardAndMouseState();
        
        
        if (wasAnyHotKeyPressedWithD) // only if no mouse keys pressed during...
            return nil; // suppress the D key's output if it was used to interact with the mouse
        else
            
        if (wasOtherKeyPressedWithD) {
            return event;
        }
            
        else
            {   // if no key was pressed with D then we simply return the D, but we have to create both a keydown+keyup because we swallowed the original keydown for D
                //sendKey(proxy, 0x02);
                sendKey(proxy, 0x02);
                return nil;
            }
    }
    else
    
    if (isDirectionKey(keycode)) { // H,J,K, -Key released
        
        if (*(getDIsPressed())) { // while D is pressed
            
            *(getMovementDirection())   = 0; // stop all movements if any movement direction key is released - better would be to go back to other direction that may still be held.
            
            *(getScrollDirection())     = 0;
            
            return nil; //swallow the key-release event
        }
    }
    else
    
    if (keycode == 0x09) { // V-Key up triggered, release mouse button if we have triggered it;
        postMouseLeftButtonUpIfNotPosted();
        if (*(getDIsPressed())) return nil; // swallow key-event for V-key if D is still being held
    }
    else

    if (keycode == 45) { // N-Key up
        
        if (*(getDIsPressed())) return nil; // swallow key-event for N-key if D is still being held
    }
    else

    if (keycode == 11) { // B-Key up
        
        if (*(getDIsPressed())) return nil; // swallow key-event for B-key if D is still being held
    }
    else

        
        
    if (keycode == 0x01) { // S-Key up triggered
        
        *(getScrollKeyIsHeld())          = 0;
        *(getScrollDirection())          =' ';
        if (*(getDIsPressed())) return nil; // swallow key-event for S-key if D is still being held
    }
    else
        
    if (keycode == 0x03) { // F-Key released, stop mouse acceleration
        
        //*(getAccelerateActive())        = 0; we are toggling it on key-down, not watching for held down key
        
        if (*(getDIsPressed())) return nil; // swallow key-event for F-key if D is still being held
    }
    
    else {
        // something else was released
        
        /*
        if (*(getWasOtherKeyPressedWithD())) { //other key was released, while D is still being held
            
        }
         */
        
    }
    
    
    return event;
}



// This callback will be invoked every time there is a keystroke.
//
CGEventRef
myCGEventCallback(CGEventTapProxy proxy, CGEventType type,
                  CGEventRef event, void *refcon)
{
    // Paranoid sanity check.
    if ((type != kCGEventKeyDown) && (type != kCGEventKeyUp))
        return event;
    

    if (type == kCGEventKeyDown) return handleKeyDown(event, proxy);
    if (type == kCGEventKeyUp)   return handleKeyUp(event, proxy);

    
    return nil;
}


void addKeyListenerRunLoop (void)
{
    CFMachPortRef      eventTap;
    CGEventMask        eventMask;
    CFRunLoopSourceRef runLoopSource;
    
    // Create an event tap. We are interested in key presses.
    eventMask = ((1 << kCGEventKeyDown) | (1 << kCGEventKeyUp));
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0,
                                eventMask, myCGEventCallback, NULL);
    if (!eventTap) {
        fprintf(stderr, "failed to create event tap\n");
        exit(1);
    }
    
    // Create a run loop source.
    runLoopSource = CFMachPortCreateRunLoopSource(
                                                  kCFAllocatorDefault, eventTap, 0);
    
    // Add to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
                       kCFRunLoopCommonModes);
    
    // Enable the event tap.
    CGEventTapEnable(eventTap, true);

    /*
   
    // Set it all running.
    CFRunLoopRun();
    
    // In a real program, one would have arranged for cleaning up.
    
    exit(0);
     */
}

