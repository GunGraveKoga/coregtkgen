/*
 * GIRProperty.h
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
#import "GIR/GIRArray.h"
#import "GIR/GIRBase.h"
#import "GIR/GIRDoc.h"
#import "GIR/GIRType.h"

@interface GIRProperty : GIRBase
{
	OFString *name;
	OFString *transferOwnership;
	OFString *version;
	OFString *deprecatedVersion;
	GIRDoc *doc;
	GIRDoc *docDeprecated;
	GIRType *type;
	BOOL allowNone;
	BOOL constructOnly;
	BOOL readable;
	BOOL deprecated;
	OFString *construct;
	OFString *writable;
	GIRArray *array;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *transferOwnership;
@property (nonatomic, retain) OFString *version;
@property (nonatomic, retain) OFString *deprecatedVersion;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic) BOOL allowNone;
@property (nonatomic) BOOL constructOnly;
@property (nonatomic) BOOL readable;
@property (nonatomic) BOOL deprecated;
@property (nonatomic, retain) OFString *construct;
@property (nonatomic, retain) OFString *writable;
@property (nonatomic, retain) GIRArray *array;

@end
