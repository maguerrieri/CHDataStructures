/*
 CHDataStructures.framework -- CHSortedSetTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <XCTest/XCTest.h>
#import "CHSortedSet.h"

#import "CHAbstractBinarySearchTree_Internal.h"
#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHRedBlackTree.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

#define NonConcreteClass() \
(self.classUnderTest == nil || self.classUnderTest == CHAbstractBinarySearchTree.class)

#define returnIfAbstract() do { if (NonConcreteClass()) { return; } } while (false);

#pragma mark -

@interface CHSortedSetTest : XCTestCase {
	NSArray *objects;
	NSEnumerator *e;
	id anObject;
}

@property (readwrite, strong) id<CHSortedSet> set;

@property (readwrite, strong) NSArray <NSString *> *testArray;

@end

@implementation CHSortedSetTest

- (Class)classUnderTest {
	return nil;
}

- (id<CHSortedSet>)createSet {
    return [[self.classUnderTest alloc] init];
}

- (NSArray <NSString *> *)allObjectsForSet:(id<CHSortedSet>)set {
    return [set allObjects];
}

- (void)setUp {
	self.set = [self createSet];
    self.testArray = @[@"A", @"B", @"C", @"D", @"E"];
}

- (void)testAddObject {
    XCTAssertEqual(self.set.count, 0);
    XCTAssertThrows([self.set addObject:nil]);
    XCTAssertEqual(self.set.count, 0);
    
    // Try adding distinct objects
    NSUInteger expectedCount = 0;
    for (NSString *object in self.testArray) {
        [self.set addObject:object];
        XCTAssertEqual(self.set.count, ++expectedCount);
    }
    XCTAssertEqual(self.set.count, self.testArray.count);
    
    // Test adding identical object—should be replaced, and count stay the same
    [self.set addObject:@"A"];
    XCTAssertEqual(self.set.count, self.testArray.count);
}

- (void)testAllObjects {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertEqualObjects([self.set allObjects], @[]);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertEqualObjects([self.set allObjects], self.testArray);
}

- (void)testAnyObject {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNil([self.set anyObject]);
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertNotNil([self.set anyObject]);
}

- (void)testContainsObject {
    returnIfAbstract();
    
	// Test contains for nil and non-member objects
	XCTAssertNoThrow([self.set containsObject:nil]);
	XCTAssertFalse([self.set containsObject:nil]);
	XCTAssertNoThrow([self.set containsObject:@"bogus"]);
	XCTAssertFalse([self.set containsObject:@"bogus"]);
    
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertNoThrow([self.set containsObject:@"bogus"]);
	XCTAssertFalse([self.set containsObject:@"bogus"]);
    
	// Test contains for each object in the set 
    for (NSString *string in self.testArray) {
		XCTAssertTrue([self.set containsObject:string]);
    }
}

- (void)testFirstObject {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set firstObject]);
	XCTAssertNil([self.set firstObject]);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertNoThrow([self.set firstObject]);
	XCTAssertEqualObjects([self.set firstObject], @"A");
}

- (void)testInit {
    returnIfAbstract();
    
	XCTAssertNotNil(self.set);
	XCTAssertEqual([self.set count], 0);
}

- (void)testInitWithArray {
    returnIfAbstract();
    
	id<CHSortedSet> set = [[self.classUnderTest alloc] initWithArray:self.testArray];
	XCTAssertEqual(set.count, self.testArray.count);
}

- (void)testIsEqual {
    returnIfAbstract();
    
	// Calls to -isEqual: exercise -isEqualToSortedSet: by extension
	XCTAssertTrue([self.set isEqual:self.set]);
    
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertTrue([self.set isEqual:self.set]);
	XCTAssertFalse([self.set isEqual:[self createSet]]);
	XCTAssertFalse([self.set isEqual:[[NSObject alloc] init]]);
}

- (void)testLastObject {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set lastObject]);
	XCTAssertNil([self.set lastObject]);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertNoThrow([self.set lastObject]);
	XCTAssertEqualObjects([self.set lastObject], @"E");
}

- (void)testMember {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set member:nil]);
	XCTAssertNoThrow([self.set member:@"bogus"]);
	XCTAssertNil([self.set member:nil]);
	XCTAssertNil([self.set member:@"bogus"]);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
    for (NSString *string in self.testArray) {
		XCTAssertEqualObjects([self.set member:anObject], string);
    }
	XCTAssertNoThrow([self.set member:@"bogus"]);
	XCTAssertNil([self.set member:@"bogus"]);
}

- (void) testObjectEnumerator {
    returnIfAbstract();
	
	// Enumerator shouldn't retain collection if there are no objects
//    XCTAssertEqual([self.set retainCount], (NSUInteger)1);
	e = [self.set objectEnumerator];
	XCTAssertNotNil(e);
//    XCTAssertEqual([self.set retainCount], (NSUInteger)1);
	XCTAssertNil([e nextObject]);

	// Enumerator should retain collection when it has 1+ objects, release on 0
	[self.set addObjectsFromArray:self.testArray];
	e = [self.set objectEnumerator];
	XCTAssertNotNil(e);
//    XCTAssertEqual([self.set retainCount], (NSUInteger)2);
	// Grab one object from the enumerator
	[e nextObject];
//    XCTAssertEqual([self.set retainCount], (NSUInteger)2);
	// Empty the enumerator of all objects
	[e allObjects];
//    XCTAssertEqual([self.set retainCount], (NSUInteger)1);
	
	// Enumerator should release collection on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
//    XCTAssertEqual([self.set retainCount], (NSUInteger)1);
	e = [self.set objectEnumerator];
	XCTAssertNotNil(e);
//    XCTAssertEqual([self.set retainCount], (NSUInteger)2);
	[pool drain]; // Force deallocation of autoreleased enumerator
//    XCTAssertEqual([self.set retainCount], (NSUInteger)1);
	
	// Test mutation in the middle of enumeration
	e = [self.set objectEnumerator];
	XCTAssertNoThrow([e nextObject]);
	[self.set addObject:@"bogus"];
	XCTAssertThrows([e nextObject]);
	XCTAssertThrows([e allObjects]);
}

- (void)testRemoveObject { }

- (void)testRemoveAllObjects {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set removeAllObjects]);
	XCTAssertEqual([self.set count], 0);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertEqual(self.set.count, self.testArray.count);
	XCTAssertNoThrow([self.set removeAllObjects]);
	XCTAssertEqual(self.set.count, 0);
}

- (void)testRemoveFirstObject {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set removeFirstObject]);
	XCTAssertEqual(self.set.count, 0);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertEqualObjects([self.set firstObject], @"A");
	XCTAssertEqual(self.set.count, self.testArray.count);
	XCTAssertNoThrow([self.set removeFirstObject]);
	XCTAssertEqualObjects([self.set firstObject], @"B");
	XCTAssertEqual([self.set count], [self.testArray count] - 1);
}

- (void) testRemoveLastObject {
    returnIfAbstract();
    
	// Try with empty sorted set
	XCTAssertNoThrow([self.set removeLastObject]);
	XCTAssertEqual([self.set count], (NSUInteger)0);
    
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	XCTAssertEqualObjects([self.set lastObject], @"E");
	XCTAssertEqual([self.set count], [self.testArray count]);
	XCTAssertNoThrow([self.set removeLastObject]);
	XCTAssertEqualObjects([self.set lastObject], @"D");
	XCTAssertEqual([self.set count], [self.testArray count]-1);
}

- (void) testReverseObjectEnumerator {
	returnIfAbstract();
    
	// Try with empty sorted set
	NSEnumerator *reverse = [self.set reverseObjectEnumerator];
	XCTAssertNotNil(reverse);
	XCTAssertNil([reverse nextObject]);
	// Try with populated sorted set
	[self.set addObjectsFromArray:self.testArray];
	reverse = [self.set reverseObjectEnumerator];
	e = [[self.set allObjects] reverseObjectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertEqualObjects([reverse nextObject], anObject);
	}
}

- (void) testSet {
	returnIfAbstract();
    
	NSArray *order = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	[self.set addObjectsFromArray:order];
	XCTAssertEqualObjects([self.set set], [NSSet setWithArray:order]);
}

- (void) testSubsetFromObjectToObject {
	returnIfAbstract();
    
	NSArray *acdeg = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",@"G",nil];
	NSArray *acde  = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",nil];
	NSArray *aceg  = [NSArray arrayWithObjects:@"A",@"C",@"E",@"G",nil];
	NSArray *ag    = [NSArray arrayWithObjects:@"A",@"G",nil];
	NSArray *cde   = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *cdeg  = [NSArray arrayWithObjects:@"C",@"D",@"E",@"G",nil];
	NSArray *subset;
	
	id<CHSortedSet> set = [[[self classUnderTest] alloc] initWithArray:acdeg];
	
	// Test including all objects (2 nil params, or match first and last)
	subset = [[set subsetFromObject:nil toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
	
	// Test including no objects
	subset = [[set subsetFromObject:@"H" toObject:@"I" options:0] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"A" toObject:@"B"
	           options:CHSubsetExcludeHighEndpoint|CHSubsetExcludeLowEndpoint] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"H" toObject:@"A" options:CHSubsetExcludeHighEndpoint] allObjects];
	XCTAssertEqual([subset count], 0ul);
	subset = [[set subsetFromObject:@"H" toObject:@"" options:0] allObjects];
	XCTAssertEqual([subset count], 0ul);
	
	// Test excluding elements at the end
	subset = [[set subsetFromObject:nil toObject:@"F" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:nil toObject:@"E" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:@"A" toObject:@"F" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	subset = [[set subsetFromObject:@"A" toObject:@"E" options:0] allObjects];
	XCTAssertEqualObjects(subset, acde);
	
	// Test excluding elements at the start
	subset = [[set subsetFromObject:@"B" toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	subset = [[set subsetFromObject:@"C" toObject:nil options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	
	subset = [[set subsetFromObject:@"B" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	subset = [[set subsetFromObject:@"C" toObject:@"G" options:0] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	
	// Test excluding elements in the middle (parameters in reverse order)
	subset = [[set subsetFromObject:@"E" toObject:@"C" options:0] allObjects];
	XCTAssertEqualObjects(subset, aceg);
	
	subset = [[set subsetFromObject:@"F" toObject:@"B" options:0] allObjects];
	XCTAssertEqualObjects(subset, ag);
	
	// Test using options to exclude zero, one, or both endpoints.
	CHSubsetConstructionOptions o;
	
	o = CHSubsetExcludeLowEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, cdeg);
	
	o = CHSubsetExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, acde);
	
	o = CHSubsetExcludeLowEndpoint | CHSubsetExcludeHighEndpoint;
	subset = [[set subsetFromObject:@"A" toObject:@"G" options:o] allObjects];
	XCTAssertEqualObjects(subset, cde);
	
	subset = [[set subsetFromObject:nil toObject:nil options:o] allObjects];
	XCTAssertEqualObjects(subset, acdeg);
}

- (void)testNSCoding {
	returnIfAbstract();
    
	NSArray <NSString *> *order = @[@"B", @"M", @"C", @"K", @"D", @"I", @"E", @"G", @"J", @"L", @"N", @"F", @"A", @"H"];
	NSArray <NSString *> *before, *after;
    
	[self.set addObjectsFromArray:order];
	XCTAssertEqual([self.set count], [order count]);
    before = [self allObjectsForSet:self.set];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.set];
	self.set = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	XCTAssertEqual([self.set count], [order count]);
    after = [self allObjectsForSet:self.set];
	if ([self classUnderTest] != [CHTreap class])
		XCTAssertEqualObjects(before, after);
}

- (void)testNSCopying {
	returnIfAbstract();
    
	id<CHSortedSet> copy = [[self.set copy] autorelease];
	XCTAssertNotNil(copy);
	XCTAssertEqual([copy count], (NSUInteger)0);
	XCTAssertEqual([self.set hash], [copy hash]);
	
	[self.set addObjectsFromArray:self.testArray];
	copy = [[self.set copy] autorelease];
	XCTAssertNotNil(copy);
	XCTAssertEqual([copy count], [self.testArray count]);
	XCTAssertEqual([self.set hash], [copy hash]);
    XCTAssertEqualObjects([self allObjectsForSet:self.set], [self allObjectsForSet:copy]);
}

- (void)testNSFastEnumeration {
	returnIfAbstract();
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
    for (NSUInteger number = 1; number <= limit; number++) {
		[self.set addObject:@(number)];
    }
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in self.set) {
		XCTAssertEqual([object unsignedIntegerValue], expected++);
		count++;
	}
	XCTAssertEqual(count, limit);
	
	BOOL raisedException = NO;
	@try {
        for (id object in self.set) {
            (void)object;
			[self.set addObject:@(-1)];
        }
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	XCTAssertTrue(raisedException);
}

@end

#pragma mark -

@interface CHSearchTreeTest : CHSortedSetTest

@end

@implementation CHSearchTreeTest

- (NSArray <NSString *> *)allSetObjects {
    return [(id<CHSearchTree>)self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder];
}

@end

#pragma mark -

@interface CHAbstractBinarySearchTree (Test)

- (id) headerObject;

@end

@implementation CHAbstractBinarySearchTree (Test)

- (id) headerObject {
	return header->object;
}

@end

@interface CHAbstractBinarySearchTreeTest : CHSortedSetTest

@property (readwrite, strong) CHAbstractBinarySearchTree *set;

@end

@implementation CHAbstractBinarySearchTreeTest

@dynamic set;

- (Class)classUnderTest {
	return CHAbstractBinarySearchTree.class;
}

- (void)testAddObject {
    // This method should be unsupported in the abstract parent class.
    XCTAssertThrows([self.set addObject:nil]);
}

- (void)testRemoveObject {
    // This method should be unsupported in the abstract parent class.
    XCTAssertThrows([self.set removeObject:nil]);
}

- (void) testAllObjectsWithTraversalOrder {
    returnIfAbstract();
    
    [self.set addObjectsFromArray:self.testArray];
	// Also tests -objectEnumeratorWithTraversalOrder: implicitly
    XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
                         ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil]));
    XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
                         ([NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil]));
	// NOTE: Individual subclasses should test pre/post/level-order traversals
}

- (void)testDescription {
	XCTAssertEqualObjects([self.set description], [[self.set allObjects] description]);
}

- (void)testHeaderObject {
	id headerObject = [self.set headerObject];
	XCTAssertNotNil(headerObject);
//    XCTAssertThrows([headerObject retain]);
//    XCTAssertThrows([headerObject release]);
//    XCTAssertThrows([headerObject autorelease]);
}

- (void) testIsEqualToSearchTree {
	if ([self class] != [CHAbstractBinarySearchTreeTest class])
		return;
	NSMutableArray *equalTrees = [NSMutableArray array];
	NSArray *treeClasses = [NSArray arrayWithObjects:
							[CHAnderssonTree class],
							[CHAVLTree class],
							[CHRedBlackTree class],
							[CHTreap class],
							[CHUnbalancedTree class],
							nil];
	e = [treeClasses objectEnumerator];
	Class theClass;
	while (theClass = [e nextObject]) {
		[equalTrees addObject:[[theClass alloc] initWithArray:self.testArray]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalTrees addObject:[equalTrees objectAtIndex:0]];
	
	NSArray *sortedSetClasses = [[NSArray alloc] initWithObjects:
								 [CHAnderssonTree class],
								 [CHAVLTree class],
								 [CHRedBlackTree class],
								 [CHTreap class],
								 [CHUnbalancedTree class],
								 nil];
	id<CHSearchTree> tree1, tree2;
	for (NSUInteger i = 0; i < [sortedSetClasses count]; i++) {
		tree1 = [equalTrees objectAtIndex:i];
		tree2 = [equalTrees objectAtIndex:i+1];
		XCTAssertEqual([tree1 hash], [tree2 hash]);
		XCTAssertEqualObjects(tree1, tree2);
	}
	XCTAssertFalse([tree1 isEqualToSearchTree:[NSArray array]]);
	XCTAssertThrowsSpecificNamed([tree1 isEqualToSearchTree:[NSString string]], NSException, NSInvalidArgumentException);
}

@end

#pragma mark -

@interface CHAnderssonTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHAnderssonTreeTest

- (Class) classUnderTest {
	return [CHAnderssonTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 645
}

- (void) testAddObject {
	XCTAssertEqual([self.set count], (NSUInteger)0);
	XCTAssertThrows([self.set addObject:nil]);
	XCTAssertEqual([self.set count], (NSUInteger)0);
	
	[self.set addObjectsFromArray:objects];
	XCTAssertEqual([self.set count], [objects count]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",@"G",@"J",@"I",@"K",@"N",@"M",@"O",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",@"J",@"H",@"M",@"O",@"N",@"L",@"E",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"J",@"M",@"O",@"G",@"I",@"K",nil]));
	
	// Test adding identical object--should be replaced, and count stay the same
	[self.set addObject:@"A"];
	XCTAssertEqual([self.set count], [objects count]);
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node],
						 @"[1]\t\"A B C\"");
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n1\"];\n");
	free(node);
}

- (void) testRemoveObject {
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	[self.set addObjectsFromArray:objects];
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	XCTAssertEqual([self.set count], [objects count]);
	
	[self.set removeObject:@"J"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",@"I",@"M",@"O",@"G",@"K",nil]));
	[self.set removeObject:@"N"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",@"I",@"M",@"K",@"O",nil]));
	[self.set removeObject:@"H"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",@"K",@"M",@"O",nil]));
	[self.set removeObject:@"D"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",@"M",@"O",nil]));
	[self.set removeObject:@"C"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",@"O",nil]));
	[self.set removeObject:@"K"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G",nil]));
	[self.set removeObject:@"M"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O",nil]));
	[self.set removeObject:@"B"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"A",@"I",@"F",@"L",@"G",@"O",nil]));
	[self.set removeObject:@"A"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"I",@"G",@"L",@"O",nil]));
	[self.set removeObject:@"G"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"L",@"I",@"O",nil]));
	[self.set removeObject:@"E"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil]));
	[self.set removeObject:@"F"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"L",@"I",@"O",nil]));
	[self.set removeObject:@"L"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"I",@"O",nil]));
	[self.set removeObject:@"I"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"O",nil]));
}

@end

#pragma mark -

@interface CHAVLTree (Test)

- (void) verify;

@end

@implementation CHAVLTree (Test)

- (NSInteger) heightForSubtree:(CHBinaryTreeNode*)node
                    isBalanced:(BOOL*)isBalanced
                   errorString:(NSMutableString*)balanceErrors {
	if (node == sentinel)
		return 0;
	NSInteger leftHeight  = [self heightForSubtree:node->left isBalanced:isBalanced errorString:balanceErrors];
	NSInteger rightHeight = [self heightForSubtree:node->right isBalanced:isBalanced errorString:balanceErrors];
	if (node->balance != (rightHeight-leftHeight)) {
		[balanceErrors appendFormat:@". | At \"%@\" should be %ld, was %d",
		 node->object, (rightHeight-leftHeight), node->balance];
		*isBalanced = NO;
	}
	return MAX(leftHeight, rightHeight) + 1;
}

- (void) verify {
	BOOL isBalanced = YES;
	NSMutableString *balanceErrors = [NSMutableString string];
	[self heightForSubtree:header->right
				isBalanced:&isBalanced
			   errorString:balanceErrors];
	
	if (!isBalanced) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Violation of AVL balance factors%@", balanceErrors];
	}
}

@end

@interface CHAVLTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHAVLTreeTest

- (Class) classUnderTest {
	return [CHAVLTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
}

- (void) testAddObject {
	[super testAddObject];
	
	[self.set removeAllObjects];
	e = [objects objectEnumerator];
	
	// Test adding objects one at a time and verify the ordering of tree nodes
	[self.set addObject:[e nextObject]]; // B
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",nil]));
	[self.set addObject:[e nextObject]]; // N
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",@"N",nil]));
	[self.set addObject:[e nextObject]]; // C
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"N",nil]));
	[self.set addObject:[e nextObject]]; // L
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"N",@"L",nil]));
	[self.set addObject:[e nextObject]]; // D
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"L",@"D",@"N",nil]));
	[self.set addObject:[e nextObject]]; // J
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"D",@"C",@"B",@"L",@"J",@"N",nil]));
}


- (void) testAllObjectsWithTraversalOrder {
	[self.set addObjectsFromArray:objects];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"B",@"A",@"C",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"C",@"B",@"F",@"E",@"I",@"H",@"G",@"D",@"K",@"M",@"O",@"N",@"L",@"J",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"L",@"B",@"G",@"K",@"N",@"A",@"C",@"E",@"H",@"M",@"O",@"F",@"I",nil]));
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node],
						 @"[ 0]\t\"A B C\"");
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n0\"];\n");
	free(node);
}

- (void) testRemoveObject {
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	[self.set addObjectsFromArray:objects];
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	XCTAssertEqual([self.set count], [objects count]);
	
	e = [objects objectEnumerator];
	
	[self.set removeObject:[e nextObject]]; // B
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"N",@"M",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // N
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M",nil]));
	[self.set removeObject:[e nextObject]]; // C
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"G",@"D",@"A",@"E",@"F",@"H",@"I",@"L",@"K",@"O",@"M",nil]));
	[self.set removeObject:[e nextObject]]; // L
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"D",@"A",@"E",@"F",@"J",@"H",@"I",@"M",@"K",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // D
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"J",@"H",@"I",@"M",@"K",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // J
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"K",@"H",@"I",@"M",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // E
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"H",@"I",@"M",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // H
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"I",@"M",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // K
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"M",@"I",@"O",nil]));
	[self.set removeObject:[e nextObject]]; // M
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"O",@"I",nil]));
	[self.set removeObject:[e nextObject]]; // O
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",@"F",@"A",@"I",nil]));
	[self.set removeObject:[e nextObject]]; // G
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"A",@"I",nil]));
	[self.set removeObject:[e nextObject]]; // A
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"I",nil]));
	[self.set removeObject:[e nextObject]]; // I
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",nil]));
}

- (void) testRemoveObjectDoubleLeft {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I",nil];
	[self.set addObjectsFromArray:objects];
	[self.set removeObject:@"A"];
	[self.set removeObject:@"D"];
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqual([self.set count], [objects count] - 2);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"C",@"B",@"E",@"J",@"H",@"G",@"I",@"K",nil]));
}

- (void) testRemoveObjectDoubleRight {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",@"E",@"G",@"I",nil];
	[self.set addObjectsFromArray:objects];
	[self.set removeObject:@"K"];
	[self.set removeObject:@"G"];
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqual([self.set count], [objects count] - 2);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"I",@"H",@"J",nil]));
}

@end

#pragma mark -

@interface CHRedBlackTree (Test)

- (void) verify;

@end

@implementation CHRedBlackTree (Test)

// Recursive method for verifying that red-black properties are not violated.
- (NSUInteger) verifySubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return 1;
	/* Test for consecutive red links */
	if (node->color == kRED) {
		if (node->left->color == kRED || node->right->color == kRED) {
			[NSException raise:NSInternalInconsistencyException
						format:@"Consecutive red below %@", node->object];
		}
	}
	NSUInteger leftBlackHeight  = [self verifySubtreeAtNode:node->left];
	NSUInteger rightBlackHeight = [self verifySubtreeAtNode:node->left];
	/* Test for invalid binary search tree */
	if ([node->left->object compare:(node->object)] == NSOrderedDescending ||
		[node->right->object compare:(node->object)] == NSOrderedAscending)
	{
		[NSException raise:NSInternalInconsistencyException
		            format:@"Binary tree violation below %@", node->object];
	}
	/* Test for black height mismatch */
	if (leftBlackHeight != rightBlackHeight && leftBlackHeight != 0) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Black height violation below %@", node->object];
	}
	/* Count black links */
	if (leftBlackHeight != 0 && rightBlackHeight != 0)
		return (node->color == kRED) ? leftBlackHeight : leftBlackHeight + 1;
	else
		return 0;
}

- (void) verify {
	sentinel->object = nil;
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHRedBlackTreeTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHRedBlackTreeTest

- (Class) classUnderTest {
	return [CHRedBlackTree class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",@"J",@"L",@"N",@"F",@"A",@"H",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 631 
}

- (void) testAddObject {
	[super testAddObject];
	[self.set removeAllObjects];
	
	e = [objects objectEnumerator];
	
	[self.set addObject:[e nextObject]]; // B
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"B",nil]));
	[self.set addObject:[e nextObject]]; // M
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"B",@"M",nil]));
	[self.set addObject:[e nextObject]]; // C
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"M",nil]));
	[self.set addObject:[e nextObject]]; // K
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"M",@"K",nil]));
	[self.set addObject:[e nextObject]]; // D
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",nil]));
	[self.set addObject:[e nextObject]]; // I
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",@"I",nil]));
	[self.set addObject:[e nextObject]]; // E
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"K",@"E",@"M",@"D",@"I",nil]));
	[self.set addObject:[e nextObject]]; // G
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",nil]));
	[self.set addObject:[e nextObject]]; // J
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",nil]));
	[self.set addObject:[e nextObject]]; // L
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",nil]));
	[self.set addObject:[e nextObject]]; // N
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N",nil]));
	[self.set addObject:[e nextObject]]; // F
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",@"J",@"L",@"N",@"F",nil]));
	[self.set addObject:[e nextObject]]; // A
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",nil]));
	[self.set addObject:[e nextObject]]; // H
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H",nil]));
	
	// Test adding identical object--should be replaced, and count stay the same
	XCTAssertEqual([self.set count], [objects count]);
	[self.set addObject:@"A"];
	XCTAssertEqual([self.set count], [objects count]);
}

- (void) testAddObjectsAscending {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",nil];
	[self.set addObjectsFromArray:objects];
	XCTAssertEqual([self.set count], [objects count]);
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"H",@"D",@"L",@"B",@"F",@"J",@"N",@"A",@"C",@"E",@"G",@"I",@"K",@"M",@"P",@"O",@"Q",@"R",nil]));
}

- (void) testAddObjectsDescending {
	objects = [NSArray arrayWithObjects:@"R",@"Q",@"P",@"O",@"N",@"M",@"L",@"K",
			   @"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[self.set addObject:anObject];
	XCTAssertEqual([self.set count], [objects count]);
	XCTAssertNoThrow([self.set verify]);
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"K",@"G",@"O",@"E",@"I",@"M",@"Q",@"C",@"F",@"H",@"J",@"L",@"N",@"P",@"R",@"B",@"D",@"A",nil]));
}

- (void) testAllObjectsWithTraversalOrder {
	[self.set addObjectsFromArray:objects];
	
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"B",@"A",@"D",@"K",@"I",@"G",@"F",@"H",@"J",@"M",@"L",@"N",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"B",@"D",@"C",@"F",@"H",@"G",@"J",@"I",@"L",@"N",@"M",@"K",@"E",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",@"G",@"J",@"L",@"N",@"F",@"H",nil]));
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node],
						 @"[ RED ]	\"A B C\"");
	node->color = kBLACK;
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node],
						 @"[BLACK]	\"A B C\"");
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=red];\n");
	node->color = kBLACK;
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node],
						 @"  \"A B C\" [color=black];\n");
	free(node);
}

- (void) testRemoveObject {
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	[self.set addObjectsFromArray:objects];
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	XCTAssertEqual([self.set count], [objects count]);
	
	NSUInteger count = [objects count];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[self.set removeObject:anObject];
		XCTAssertEqual([self.set count], --count);
		XCTAssertNoThrow([self.set verify]);
	}
}

@end

#pragma mark -

@interface CHTreap (Test)

- (void) verify; // Raises an exception on error

@end

@implementation CHTreap (Test)

// Recursive method for verifying that BST and heap properties are not violated.
- (void) verifySubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return;
	
	if (node->left != sentinel) {
		// Verify BST property
		if ([node->left->object compare:node->object] == NSOrderedDescending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation left of %@", node->object];
		// Verify heap property
		if (node->left->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation left of %@", node->object];
		// Recursively verity left subtree
		[self verifySubtreeAtNode:node->left];
	}
	
	if (node->right != sentinel) {
		// Verify BST property
		if ([node->right->object compare:node->object] == NSOrderedAscending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation right of %@", node->object];
		// Verify heap property
		if (node->right->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation right of %@", node->object];
		// Recursively verity right subtree
		[self verifySubtreeAtNode:node->right];
	}
}

- (void) verify {
	[self verifySubtreeAtNode:header->right];
}

@end

@interface CHTreapTest : CHAbstractBinarySearchTreeTest
@end

@implementation CHTreapTest

- (Class) classUnderTest {
	return [CHTreap class];
}

- (void) setUp {
	set = [self createSet];
	objects = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"I",@"F",@"L",@"C",
			   @"H",@"E",@"M",@"A",@"J",nil];
}

- (void) testAddObject {
	[super testAddObject];
	
	// Repeat a few times to try to get a decent random spread.
	for (NSUInteger tries = 1, count; tries <= 5; tries++) {
		[self.set removeAllObjects];
		count = 0;
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[self.set addObject:anObject];
			XCTAssertEqual([self.set count], ++count);
			// Can't test a specific order because of randomly-assigned priorities
			XCTAssertNoThrow([self.set verify]);
		}
	}
}

- (void) testAddObjectWithPriority {
	[super testAddObject];

	XCTAssertNoThrow([self.set addObject:@"foo" withPriority:0]);
	XCTAssertNoThrow([self.set addObject:@"foo" withPriority:CHTreapNotFound]);
	[self.set removeAllObjects];
	
	NSUInteger priority = 0;
	e = [objects objectEnumerator];
	
	// Simulate by inserting unordered elements with increasing priority
	// This artificially balances the tree, but we can test the result.
	
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // G
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"G",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // D
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"D",@"G",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // K
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"K",@"D",@"G",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // B
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"B",@"K",@"D",@"G",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // I
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"I",@"B",@"D",@"G",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // F
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"D",@"I",@"G",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // L
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"L",@"F",@"B",@"D",@"I",@"G",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // C
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"L",@"F",@"D",@"I",@"G",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // H
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"H",@"C",@"B",@"F",@"D",@"G",@"L",@"I",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // E
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // M
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // A
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"A",@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",@"I",@"K",nil]));
	[self.set addObject:[e nextObject] withPriority:(++priority)]; // J
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"J",@"A",@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"I",@"M",@"L",@"K",nil]));
}

- (void) testAllObjectsWithTraversalOrder {
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[self.set addObject:anObject];
	
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",nil]));	
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]));	
	// Test adding an existing object to the treap
	XCTAssertEqual([self.set count], [objects count]);
	[self.set addObject:@"A" withPriority:NSIntegerMin];
	XCTAssertEqual([self.set count], [objects count]);
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->priority = 123456789;
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node],
						 @"[  123456789]\t\"A B C\"");
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->priority = 123456789;
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n123456789\"];\n");
	free(node);
}

- (void) testPriorityForObject {
	// Priority value should indicate that an object not in the treap is absent.
	XCTAssertEqual([self.set priorityForObject:nil],      (NSUInteger)CHTreapNotFound);
	XCTAssertEqual([self.set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound);
	[self.set addObjectsFromArray:objects];
	XCTAssertEqual([self.set priorityForObject:nil],      (NSUInteger)CHTreapNotFound);
	XCTAssertEqual([self.set priorityForObject:@"bogus"], (NSUInteger)CHTreapNotFound);
	
	// Inserting from 'objects' with these priorities creates a known ordering.
	NSUInteger priorities[] = {8,11,13,12,1,4,5,9,6,3,10,7,2};
	
	NSUInteger index = 0;
	[self.set removeAllObjects];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[self.set addObject:anObject withPriority:(priorities[index++])];
		[self.set verify];
	}
	
	// Verify that the assigned priorities are what we expect
	index = 0;
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		XCTAssertEqual([self.set priorityForObject:anObject], priorities[index++]);
	
	// Verify the required tree structure with these objects and priorities.
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"K",@"B",@"A",@"D",@"C",@"G",@"F",@"E",@"H",@"J",@"I",@"M",@"L",nil]));
}

- (void) testRemoveObject {
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	[self.set addObjectsFromArray:objects];
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	XCTAssertEqual([self.set count], [objects count]);

	// Remove all nodes one by one, and test treap validity at each step
	NSUInteger count = [objects count];
	e = [objects objectEnumerator];
	while (anObject = [e nextObject]) {
		[self.set removeObject:anObject];
		XCTAssertEqual([self.set count], --count);
		XCTAssertNoThrow([self.set verify]);
	}
	
	// Test removing a node which has been removed from the tree
	XCTAssertEqual([self.set count], (NSUInteger)0);
	[self.set removeObject:@"bogus"];
	XCTAssertEqual([self.set count], (NSUInteger)0);
}

@end

#pragma mark -

@interface CHUnbalancedTreeTest : CHAbstractBinarySearchTreeTest {
	CHAbstractBinarySearchTree *insideTree, *outsideTree, *zigzagTree;
}
@end

@implementation CHUnbalancedTreeTest

- (Class) classUnderTest {
	return [CHUnbalancedTree class];
}

- (void) setUp {
	set = [self createSet];

	objects = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil]; // Specified using level-order travesal
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example

	outsideTree = [[CHUnbalancedTree alloc] initWithArray:
				   [NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil]];
	insideTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil]];
	zigzagTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil]];
}

- (void) testAddObject {
	[super testAddObject];
	
	[self.set removeAllObjects];
	[self.set addObjectsFromArray:objects];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 objects);
}

- (void) testAllObjectsWithTraversalOrder {
	[super testAllObjectsWithTraversalOrder];
	[self.set removeAllObjects];
	[self.set addObjectsFromArray:objects];
	
	// Test all traversal orderings by individual tree
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseAscending],
						 ([NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseDescending],
						 ([NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePostOrder],
						 ([NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",@"F",nil]));
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraverseLevelOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H",nil]));
	
	// Test pre-order traversal of some degenerate unbalanced trees
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil]));
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil]));
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil]));
	
	// Test that no matter of how a tree is structured, forward and reverse work
	NSArray *ascending = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraverseAscending], ascending);
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraverseAscending],  ascending);
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraverseAscending],  ascending);
	NSArray *descending = [NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil];
	XCTAssertEqualObjects([outsideTree allObjectsWithTraversalOrder:CHTraverseDescending], descending);
	XCTAssertEqualObjects([insideTree allObjectsWithTraversalOrder:CHTraverseDescending],  descending);
	XCTAssertEqualObjects([zigzagTree allObjectsWithTraversalOrder:CHTraverseDescending],  descending);
}

- (void) testDebugDescription {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = @"A B C";
	XCTAssertEqualObjects([self.set debugDescriptionForNode:node], @"\"A B C\"");
	free(node);

	NSMutableString *expected = [NSMutableString string];
	[expected appendFormat:@"<CHUnbalancedTree: 0x%p> = {\n", zigzagTree];
	[expected appendString:@"\t\"A\" -> \"(null)\" and \"E\"\n"
	                       @"\t\"E\" -> \"B\" and \"(null)\"\n"
	                       @"\t\"B\" -> \"(null)\" and \"D\"\n"
	                       @"\t\"D\" -> \"C\" and \"(null)\"\n"
	                       @"\t\"C\" -> \"(null)\" and \"(null)\"\n"
	                       @"}"];
	
	XCTAssertEqualObjects([zigzagTree debugDescription], expected,
						 @"Wrong string from -debugDescription.");
}

- (void) testDotGraphString {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	XCTAssertEqualObjects([self.set dotGraphStringForNode:node], @"  \"A B C\";\n");
	free(node);
	
	NSMutableString *expected = [NSMutableString string];
	[expected appendString:@"digraph CHUnbalancedTree\n{\n"];
	[expected appendFormat:@"  \"A\";\n  \"A\" -> {nil1;\"E\"};\n"
	                       @"  \"E\";\n  \"E\" -> {\"B\";nil2};\n"
	                       @"  \"B\";\n  \"B\" -> {nil3;\"D\"};\n"
	                       @"  \"D\";\n  \"D\" -> {\"C\";nil4};\n"
	                       @"  \"C\";\n  \"C\" -> {nil5;nil6};\n"];
	for (int i = 1; i <= 6; i++)
		[expected appendFormat:@"  nil%d [shape=point,fillcolor=black];\n", i];
	[expected appendFormat:@"}\n"];
	
	XCTAssertEqualObjects([zigzagTree dotGraphString], expected);
	
	// Test for empty tree
	XCTAssertEqualObjects([self.set dotGraphString],
						 @"digraph CHUnbalancedTree\n{\n  nil;\n}\n");
}

- (void) testRemoveObject {
	objects = [NSArray arrayWithObjects:
			   @"F",@"B",@"A",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];

	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	[self.set addObjectsFromArray:objects];
	XCTAssertNoThrow([self.set removeObject:nil]);
	XCTAssertNoThrow([self.set removeObject:@"bogus"]);
	XCTAssertEqual([self.set count], [objects count]);

	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	
	// 1 - Remove a node with no children
	[self.set removeObject:@"A"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil]));
	[self.set removeObject:@"K"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",nil]));
	
	// 2 - Remove a node with only a right child
	[self.set removeObject:@"C"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"B",@"E",@"D",@"J",@"I",@"G",@"H",nil]));
	[self.set removeObject:@"B"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"I",@"G",@"H",nil]));
	
	// 3 - Remove a node with only a left child
	[self.set removeObject:@"I"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"G",@"H",nil]));
	[self.set removeObject:@"J"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects:@"F",@"E",@"D",@"G",@"H",nil]));
	
	// 4 - Remove a node with two children
	[self.set removeAllObjects];
	[self.set addObjectsFromArray:[NSArray arrayWithObjects: @"B",@"A",@"E",@"C",@"D",@"F",nil]];
	
	[self.set removeObject:@"B"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"C",@"A",@"E",@"D",@"F",nil]));
	[self.set removeObject:@"C"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"D",@"A",@"E",@"F",nil]));
	[self.set removeObject:@"D"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"E",@"A",@"F",nil]));
	[self.set removeObject:@"E"];
	XCTAssertEqualObjects([self.set allObjectsWithTraversalOrder:CHTraversePreOrder],
						 ([NSArray arrayWithObjects: @"F",@"A",nil]));
}

@end
