//
//  libKey.h
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#ifndef libKey_h
#define libKey_h


void setupKeyHandlers(int * dIsPressed, int * accelerateActive, char * movementDirection, int * leftButton, int * rightButton);

void addKeyListenerRunLoop (void);

#endif /* libKey_h */
