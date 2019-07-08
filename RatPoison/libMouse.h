//
//  lib.h
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#ifndef lib_h
#define lib_h



void showAlert(NSString * textToShow);
void moveMouseBasedOnDirection(void);
void postMouseMoveEventsIfNeeded(void);
void postMouseLeftButtonDownIfNotPosted(void);
void postMouseLeftButtonUpIfNotPosted(void);
void postMouseRightButtonPressed(void);


#endif /* lib_h */
