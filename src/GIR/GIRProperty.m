/*
 * GIRProperty.m
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
#import "GIRProperty.h"

@implementation GIRProperty

@synthesize name;
@synthesize transferOwnership;
@synthesize version;
@synthesize deprecatedVersion;
@synthesize doc;
@synthesize docDeprecated;
@synthesize type;
@synthesize allowNone;
@synthesize constructOnly;
@synthesize readable;
@synthesize deprecated;
@synthesize construct;
@synthesize writable;
@synthesize array;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRProperty";
	}
	
	return self;
}

-(id)initWithDictionary:(OFDictionary *) dict
{
	self = [self init];
	
	if(self)
	{
		[self parseDictionary:dict];
	}
	
	return self;
}

-(void)parseDictionary:(OFDictionary *) dict
{
	for (OFString *key in dict)
	{	
		id value = [dict objectForKey:key];
	
		if([key isEqual:@"text"])
		{
			// Do nothing
		}
		else if([key isEqual:@"name"])
		{
			self.name = value;
		}
		else if([key isEqual:@"transfer-ownership"])
		{
			self.transferOwnership = value;
		}
		else if([key isEqual:@"version"])
		{
			self.version = value;
		}
		else if([key isEqual:@"deprecated-version"])
		{
			self.deprecatedVersion = value;
		}
		else if([key isEqual:@"doc"])
		{
			self.doc = [[GIRDoc alloc] initWithDictionary:value];
		}
		else if([key isEqual:@"doc-deprecated"])
		{
			self.docDeprecated = [[GIRDoc alloc] initWithDictionary:value];
		}
		else if([key isEqual:@"type"])
		{
			self.type = [[GIRType alloc] initWithDictionary:value];
		}
		else if([key isEqual:@"allow-none"])
		{
			self.allowNone = [value isEqual:@"1"];
		}
		else if([key isEqual:@"construct-only"])
		{
			self.constructOnly = [value isEqual:@"1"];
		}
		else if([key isEqual:@"readable"])
		{
			self.readable = [value isEqual:@"1"];
		}	
		else if([key isEqual:@"deprecated"])
		{
			self.deprecated = [value isEqual:@"1"];
		}		
		else if([key isEqual:@"construct"])
		{
			self.construct = value;
		}
		else if([key isEqual:@"writable"])
		{
			self.writable = value;
		}
		else if([key isEqual:@"array"])
		{
			self.array = [[GIRArray alloc] initWithDictionary:value];
		}				
		else
		{
			[self logUnknownElement:key];
		}
	}	
}

-(void)dealloc
{
	[name release];
	[transferOwnership release];
	[version release];
	[deprecatedVersion release];
	[doc release];
	[docDeprecated release];
	[type release];
	[construct release];
	[writable release];
	[array release];
	[super dealloc];
}

@end
