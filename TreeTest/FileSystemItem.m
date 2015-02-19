/*
     File: FileSystemItem.m
 Abstract:  The data source backend for displaying the file system.
 This object can be improved a great deal; it never frees nodes that are expanded; it also is not too lazy when it comes to computing the children (when the number of children at a level are asked for, it computes the children array).
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */


#import "FileSystemItem.h"

@interface FileSystemItem ()
@property (strong) NSString *rootPath;
@end

@implementation FileSystemItem

static FileSystemItem *rootItem = nil;

#define IsALeafNode ((id)-1)

- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)obj {
    if (self = [super init]) {
        _rootPath = path;
        relativePath = [[path lastPathComponent] copy];
        parent = obj;
    }
    return self;
}

+ (FileSystemItem *)rootItem {
   if (rootItem == nil) rootItem = [[FileSystemItem alloc] initWithPath:@"/" parent:nil];
   return rootItem;       
}

+ (FileSystemItem *)rootItemWithPath:(NSString*)path {

    if (rootItem == nil) rootItem = [[FileSystemItem alloc] initWithPath:path parent:nil];
    return rootItem;
}

- (NSArray *)children {
    if (children == NULL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
        if (valid && isDir) {
            NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
            if (!array) {   // This is unexpected
                children = [[NSMutableArray alloc] init];
            } else {
                NSInteger cnt, numChildren = [array count];
                children = [[NSMutableArray alloc] initWithCapacity:numChildren];
                for (cnt = 0; cnt < numChildren; cnt++) {
                    FileSystemItem *item = [[FileSystemItem alloc] initWithPath:[array objectAtIndex:cnt] parent:self];
                    [children addObject:item];
                    //		    [item release];
                }
            }
        } else {
            children = nil;
        }
    }
    return children;
}

- (NSString *)relativePath {
    return relativePath;
}

- (NSString *)fullPath {
//    return parent ? [[parent fullPath] stringByAppendingPathComponent:relativePath] : relativePath;
    return parent ? [[parent fullPath] stringByAppendingPathComponent:relativePath] : self.rootPath;
}

- (FileSystemItem *)childAtIndex:(NSInteger)n {
    return [[self children] objectAtIndex:n];
}


- (NSInteger)numberOfChildren {
    id tmp = [self children];
    //    return (tmp == IsALeafNode) ? (-1) : [tmp count];
    if(tmp == nil){
        NSLog(@"children: -1");
        //        return -1;
        return -1;
    } else {
        NSLog(@"children: %ld", (long)[tmp count]);
        return [tmp count];
    }
}


@end


