//
//  MPQueueTableView.h
//  Pallet
//
//  Created by Vasileios Georgitzikis on 16/7/10.
//  Copyright 2010 Tzikis. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MPQueueTableView : NSTableView
{
	IBOutlet NSMutableArray *queueArray;
    IBOutlet NSArrayController *queue;
}

@end
