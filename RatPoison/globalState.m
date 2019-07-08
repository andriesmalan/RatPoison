//
//  globalState.m
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//


int dIsPressed          = 0;
int accelerateActive    = 0;
char movementDirection  =' ';
int leftButton          = 0;
int rightButton         = 0;
int wasHotKeyPressedWithD = 0;
int wasOtherKeyPressedWithD = 0;
int scrollKeyIsHeld     = 0;
char scrollDirection    =' ';


int * getScrollKeyIsHeld(void)
{
    return &scrollKeyIsHeld;
}


int * getWasOtherKeyPressedWithD(void)
{
    return &wasOtherKeyPressedWithD;
}


int * getWasHotKeyPressedWithD(void)
{
    return &wasHotKeyPressedWithD;
}

int * getDIsPressed(void)
{
    return &dIsPressed;
}


int * getAccelerateActive(void)
{
    return &accelerateActive;
}


char * getMovementDirection(void)
{
    return &movementDirection;
}


char * getScrollDirection(void)
{
    return &scrollDirection;
}


int * getLeftButton(void)
{
    return &leftButton;
}


int * getRightButton(void)
{
    return &rightButton;
}

