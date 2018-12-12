/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  main.m
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//  Copyright-2009-2017 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MFBAppDelegate.h"
#import "Aircraft.h"
#import "CommentedImage.h"
#import "FlightProps.h"
#import "LogbookEntry.h"
#import "MFBTheme.h"

void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

void SwizzleArchivedClasses()
{
    /*
     Swizzle the classes that where we replace initwithcoder/decode
     
     Way back when, I implemented my own initwithcoder/encodewithcoder category extensions on these
     classes (before I knew what I was doing).  Alas, I need to keep those implementations, and furthermore
     the ones that come from wsdl2objC don't seem to work (or at least aren't backwards compatible).  Subclassing
     doesn't do what I want because the objects are created in the auto-generated code and hence aren't of the
     subclass type; I need to extend the actual object.
     
     It all sorta worked for a few years, but the linker warnings got more and more annoying.
     
     The correct way, it seems, to do this is to "swizzle" the functions, effectively swapping their function
     with mine.  This eliminates the linker warning (since there is no longer a name conflict) and calls my functionality
     where I want it.
     
     Swizzling code & description described at https://nshipster.com/method-swizzling/
    */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([MFBWebServiceSvc_Aircraft class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_Aircraft class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        
        Swizzle([MFBWebServiceSvc_MFBImageInfo class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_MFBImageInfo class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_ArrayOfMFBImageInfo class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_ArrayOfMFBImageInfo class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        
        Swizzle([MFBWebServiceSvc_ArrayOfCustomFlightProperty class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_ArrayOfCustomFlightProperty class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_CustomPropertyType class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_CustomPropertyType class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_CustomFlightProperty class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_CustomFlightProperty class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        
        Swizzle([MFBWebServiceSvc_LogbookEntry class], @selector(initWithCoder:), @selector(initWithCoderMFB:));
        Swizzle([MFBWebServiceSvc_LogbookEntry class], @selector(encodeWithCoder:), @selector(encodeWithCoderMFB:));
        
        // Theme support - tables suck because UIAppearance can't set primary/detail text colors.
        Swizzle([UITableViewCell class], @selector(initWithStyle:reuseIdentifier:), @selector(initWithMFBThemedStyle:reuseIdentifier:));
        Swizzle([UITableView class], @selector(dequeueReusableCellWithIdentifier:), @selector(dequeueThemedReusableCellWithIdentifier:));
    });
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        SwizzleArchivedClasses();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MFBAppDelegate class]));
    }
}
