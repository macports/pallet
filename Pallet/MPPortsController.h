/* MPPortsController */

#import <Cocoa/Cocoa.h>

@interface MPPortsController : NSArrayController
{
	NSString *searchString;
}

- (IBAction)search:(id)sender;
- (void)setSearchString:(NSString *)aString;
- (NSString *)searchString;

@end
