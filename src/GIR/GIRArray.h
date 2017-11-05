/*
 * GIRArray.h
 * This file is part of gir2objc
 *
 * Copyright (C) 2017 - Tyler Burton
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
 * Modified by the gir2objc Team, 2017. See the AUTHORS file for a
 * list of people on the gir2objc Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import "GIR/GIRBase.h"
#import "GIR/GIRType.h"

@interface GIRArray : GIRBase
{
	NSString *cType;
	NSString *name;
	int length;
	int fixedSize;
	BOOL zeroTerminated;
	GIRType *type;
}

@property (nonatomic, retain) NSString *cType;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) int length;
@property (nonatomic) int fixedSize;
@property (nonatomic) BOOL zeroTerminated;
@property (nonatomic, retain) GIRType *type;

@end
