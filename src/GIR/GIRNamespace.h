/*
 * GIRNamespace.h
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
#import "GIR/GIRBase.h"
#import "GIR/GIRClass.h"
#import "GIR/GIRConstant.h"
#import "GIR/GIREnumeration.h"
#import "GIR/GIRFunction.h"
#import "GIR/GIRInterface.h"

@interface GIRNamespace: GIRBase
{
	OFString *name;
	OFString *cSymbolPrefixes;
	OFString *cIdentifierPrefixes;
	OFMutableArray *classes;
	OFMutableArray *functions;
	OFMutableArray *enumerations;
	OFMutableArray *constants;
	OFMutableArray *interfaces;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *cSymbolPrefixes;
@property (nonatomic, retain) OFString *cIdentifierPrefixes;
@property (nonatomic, retain) OFMutableArray *classes;
@property (nonatomic, retain) OFMutableArray *functions;
@property (nonatomic, retain) OFMutableArray *enumerations;
@property (nonatomic, retain) OFMutableArray *constants;
@property (nonatomic, retain) OFMutableArray *interfaces;

@end
