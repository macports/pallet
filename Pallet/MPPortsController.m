#import "MPPortsController.h"

@implementation MPPortsController

- (NSArray *)arrangeObjects:(NSArray *)objects
{
	if (searchString == nil || [searchString isEqualToString:@""]) {
		return [super arrangeObjects:objects];
	}
	
	NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
	NSEnumerator *objectsEnumerator = [objects objectEnumerator];
	id item;
	
	// the *_as_string objects are retained to make searching easy
	while (item = [objectsEnumerator nextObject]) {
		if ([[item valueForKeyPath:@"name"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[item valueForKeyPath:@"categoriesAsString"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[item valueForKeyPath:@"description"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[item valueForKeyPath:@"long_description"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[item valueForKeyPath:@"homepage"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[item valueForKeyPath:@"maintainersAsString"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound
			) {
			[filteredObjects addObject:item];
		}
	}
	return [super arrangeObjects:filteredObjects];
}

- (IBAction)search:(id)sender
{
	[self setSearchString:[sender stringValue]];
	[self rearrangeObjects];
}

- (void)setSearchString:(NSString *)aString
{
	[aString retain];
	[searchString release];
	searchString = aString;
}

- (NSString *)searchString
{
	return searchString;
}

@end
