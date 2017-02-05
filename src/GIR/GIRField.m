/*
 * GIRField.h
 * This file is part of gir2objc
 *
 * Copyright (C) 2016 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the gir2objc Team, 2016. See the AUTHORS file for a
 * list of people on the gir2objc Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import <ObjFW/ObjFW.h>
#import "GIRField.h"

@implementation GIRField

@synthesize name;
@synthesize isPrivate;
@synthesize readable;
@synthesize bits;
@synthesize type;
@synthesize array;

- (id) init {
    self = [super init];

    if (self) {
        self.elementTypeName = @"GIRField";
    }

    return self;
}

- (id) initWithDictionary:(OFDictionary *)dict {
    self = [self init];

    if (self) {
        [self parseDictionary:dict];
    }

    return self;
}

- (void) parseDictionary:(OFDictionary *)dict {
    for (OFString * key in dict) {
        id value = [dict objectForKey:key];

        if ([key isEqual:@"text"]) {
            // Do nothing
        } else if ([key isEqual:@"name"]) {
            self.name = value;
        } else if ([key isEqual:@"private"]) {
            self.isPrivate = [value isEqual:@"1"];
        } else if ([key isEqual:@"readable"]) {
            self.readable = [value isEqual:@"1"];
        } else if ([key isEqual:@"bits"]) {
            self.bits = [value decimalValue];
        } else if ([key isEqual:@"type"]) {
            self.type = [[GIRType alloc] initWithDictionary:value];
        } else if ([key isEqual:@"array"]) {
            self.array = [[GIRArray alloc] initWithDictionary:value];
        } else {
            [self logUnknownElement:key];
        }
    }
} /* parseDictionary */

- (void) dealloc {
    [name release];
    [type release];
    [array release];
    [super dealloc];
}

@end
