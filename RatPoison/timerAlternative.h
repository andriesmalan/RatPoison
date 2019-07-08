//
//  timerAlternative.h
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#ifndef timerAlternative_h
#define timerAlternative_h

typedef void (*CallBackFuncType)(void);

void setupTimer( CallBackFuncType funcToCall );


#endif /* timerAlternative_h */
