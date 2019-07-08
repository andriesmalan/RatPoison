//
//  timerAlternative.m
//  test
//
//  Created by Andries Malan on 2017/07/24.
//  Copyright © 2017 Andries Malan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (*CallBackFuncType)(void);

void setupTimer( CallBackFuncType funcToCall  ) {
    double delayInMilliseconds = 500.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInMilliseconds * NSEC_PER_MSEC));
    dispatch_after(popTime, /*dispatch_get_main_queue()*/dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
        // callback invocation
        //showAlert(@"hello");
        if (funcToCall) funcToCall();
        setupTimer(funcToCall);
        
    });
}
