//
//  StatePredicateTemplate.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/16/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "StatePredicateTemplate.h"


@implementation StatePredicateTemplate

- (id)init {
    [super init];
    states = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithInt:MPPortStateUnknown], @"Any",                // 0
                [NSNumber numberWithInt:MPPortStateActive], @"Installed",           // 2
                [NSNumber numberWithInt:MPPortStateOutdated], @"Outdated",          // 4
                [NSNumber numberWithInt:MPPortStateNotInstalled], @"Not Installed", // 5
                nil];
    return self;
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *)subpredicates {
    // Get the original comparison predicate
    NSComparisonPredicate *predicate = (NSComparisonPredicate *)[super predicateWithSubpredicates:subpredicates];
    // Transform the right expression to a constant int (see the states Dictionary)
    int rightExpressionAsInt = [[states objectForKey:[[predicate rightExpression] constantValue]] intValue];
    
    NSExpression *rightExpression;
    NSPredicateOperatorType type;
    
    if (rightExpressionAsInt == MPPortStateActive) { 
        // "Installed" means Up-to-Date or Outdated (state == 2 OR state == 4)
        NSArray *installedPredicates = [NSArray arrayWithObjects:
                        [NSPredicate predicateWithFormat:@"state == %d", MPPortStateActive],
                        [NSPredicate predicateWithFormat:@"state == %d", MPPortStateOutdated], 
                        nil];
        return [NSCompoundPredicate orPredicateWithSubpredicates:installedPredicates];
        
    } else if (rightExpressionAsInt == MPPortStateUnknown) {
        // Any means state >= 2
        rightExpression = [NSExpression expressionForConstantValue:[states objectForKey:@"Installed"]];
        type = NSGreaterThanOrEqualToPredicateOperatorType;
    } else {
        // state == MPPortStateConstant
        NSString *rightExpressionAsString = [[predicate rightExpression] constantValue];
        rightExpression = [NSExpression expressionForConstantValue:[states objectForKey:rightExpressionAsString]];
        type = [predicate predicateOperatorType];
    }
    
    return [NSComparisonPredicate predicateWithLeftExpression:[predicate leftExpression]
                                              rightExpression:rightExpression
                                                     modifier:[predicate comparisonPredicateModifier]
                                                         type:type
                                                      options:[predicate options]];
}

@end
