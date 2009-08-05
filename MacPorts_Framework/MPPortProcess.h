//
//  MPPortProcess.h
//  MacPorts.Framework
//
//  Created by Juan Germán Castañeda Echevarría on 7/9/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#include <tcl.h>

@interface MPPortProcess : NSObject {
    Tcl_Interp *interpreter;
    NSString *PKGPath;
}


- (oneway void)evaluateString:(bycopy id)statement;

@end
