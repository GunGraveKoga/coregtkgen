/*
 * CGTKUtil.m
 * This file is part of CoreGTKGen
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the CoreGTK Team, 2016. See the AUTHORS file for a
 * list of people on the CoreGTK Team.
 * See the ChangeLog files for a list of changes.
 *
 */

/*
 * Objective-C imports
 */
#import "Generator/CGTKUtil.h"

#include <wctype.h>
#include <wchar.h>

@implementation CGTKUtil

static OFMutableArray * arrTrimMethodName;
static OFMutableDictionary * dictConvertType;
static OFMutableDictionary * dictGlobalConf;
static OFMutableDictionary * dictSwapTypes;
static OFMutableDictionary * dictExtraImports;
static OFMutableDictionary * dictExtraMethods;

+ (OFString *) convertUSSToCamelCase:(OFString *)input {
    OFString * output = [self convertUSSToCapCase:input];

    OFString * result;

    if ([output length] > 1) {
        result =  [OFString stringWithFormat:@"%@%@", [[output substringWithRange:of_range(0, 1)] lowercaseString], [output substringWithRange:of_range(1, (output.length - 1))]];
    } else {
        result = [output lowercaseString];
    }

    return result;
} /* convertUSSToCamelCase */

+ (OFString *) convertUSSToCapCase:(OFString *)input {
    OFMutableString * output = [OFMutableString stringWithString:input];

    [output replaceOccurrencesOfString:@"_" withString:@" "];
    [output deleteEnclosingWhitespaces];
    [output capitalize];
    [output replaceOccurrencesOfString:@" " withString:@""];
    [output makeImmutable];
    /*
     * OFArray * inputItems = [input componentsSeparatedByString:@"_"];
     *
     * BOOL previousItemWasSingleChar = NO;
     *
     * for (OFString * item in inputItems) {
     * if ([item length] > 1) {
     *  // Special case where we don't strand single characters
     *  if (previousItemWasSingleChar) {
     *      [output appendString:item];
     *  } else {
     *      [output appendFormat:@"%@%@", [[item substringWithRange:of_range(0, 1)] uppercaseString], [item substringWithRange:of_range(1, (output.length - 1))]];
     *  }
     *  previousItemWasSingleChar = NO;
     * } else {
     *  [output appendString:[item uppercaseString]];
     *  previousItemWasSingleChar = YES;
     * }
     * }
     */
    return output;
} /* convertUSSToCapCase */

+ (BOOL) isTypeSwappable:(OFString *)str {
    return [str isEqual:@"OFArray*"] || ![[CGTKUtil swapTypes:str] isEqual:str];
}

+ (OFString *) convertFunctionToInit:(OFString *)func {
    of_range_t range = [func rangeOfString:@"New"];

    if (range.location == OF_NOT_FOUND) {
        range = [func rangeOfString:@"new"];
    }

    if (range.location == OF_NOT_FOUND) {
        return nil;
    } else {
        size_t pos = range.location + 3;
        return [OFString stringWithFormat:@"init%@", [func substringWithRange:of_range(pos, (func.length - pos))]];
    }
}

+ (void) addToTrimMethodName:(OFString *)val {
    if (arrTrimMethodName == nil) {
        arrTrimMethodName = [[OFMutableArray alloc] init];
    }

    if ([arrTrimMethodName indexOfObject:val] == OF_NOT_FOUND) {
        [arrTrimMethodName addObject:val];
    }
}

+ (OFString *) trimMethodName:(OFString *)meth {
    if (arrTrimMethodName == nil) {
        arrTrimMethodName = [[OFMutableArray alloc] init];
    }

    OFString * longestMatch = nil;

    for (OFString * el in arrTrimMethodName) {
        if ([meth hasPrefix:el]) {
            if (longestMatch == nil) {
                longestMatch = el;
            } else if (longestMatch.length < el.length) {
                // Found longer match
                longestMatch = el;
            }
        }
    }

    if (longestMatch != nil) {
        return [meth substringWithRange:of_range(longestMatch.length, (meth.length - longestMatch.length))];
    }

    return meth;
} /* trimMethodName */

+ (OFString *) getFunctionCallForConstructorOfType:(OFString *)cType withConstructor:(OFString *)cCtor {
    return [OFString stringWithFormat:@"[super initWithGObject:(GObject *)%@]", cCtor];
}

+ (OFString *) selfTypeMethodCall:(OFString *)type {
    size_t i = 0;

    // Convert CGTKFooBar into [self FOOBAR]
    if ([type hasPrefix:@"CGTK"]) {
        type = [CGTKUtil swapTypes:type];

        return [OFString stringWithFormat:@"[self %@]", [[type substringWithRange:of_range(3, [type length] - 3)] uppercaseString]];
    }
    // Convert GtkFooBar into GTK_FOO_BAR([self GOBJECT])
    else if ([type hasPrefix:@"Gtk"]) {
        OFMutableString * result = [[OFMutableString alloc] init];

        // Special logic for GTK_GL_AREA
        if ([type isEqual:@"GtkGLArea"]) {
            [result appendString:@"GTK_GL_AREA"];
        } else {
            // Special logic for things like GtkHSV
            int countBetweenUnderscores = 0;

            for (i = 0; i < [type length]; i++) {
                // Current character
                OFString * currentChar = [type substringWithRange:of_range(i, 1)];

                if (i != 0 && iswupper([currentChar characterAtIndex:0]) && countBetweenUnderscores > 1) {
                    // if (i != 0 && [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[currentChar characterAtIndex:0]] && countBetweenUnderscores > 1) {
                    [result appendFormat:@"_%@", [currentChar uppercaseString]];
                    countBetweenUnderscores = 0;
                } else {
                    [result appendString:[currentChar uppercaseString]];
                    countBetweenUnderscores++;
                }
            }
        }

        [result appendString:@"([self GOBJECT])"];

        return result;
    } else {
        return type;
    }
} /* selfTypeMethodCall */

+ (OFString *) swapTypes:(OFString *)str {

    if (dictSwapTypes == nil) {
        dictSwapTypes = [[OFString stringWithContentsOfFile:@"Config/swap_types.map"] JSONValue]; // [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/swap_types.map"];
    }

    OFString * val = [dictSwapTypes objectForKey:str];

    return (val == nil) ? str : val;
}

+ (OFString *) convertType:(OFString *)fromType withName:(OFString *)name toType:(OFString *)toType {
    if (dictConvertType == nil) {
        dictConvertType = [[OFString stringWithContentsOfFile:@"Config/convert_type.map"] JSONValue]; // [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/convert_type.map"];
    }

    OFMutableDictionary * outerDict = [dictConvertType objectForKey:fromType];

    if (outerDict == nil) {
        if ([fromType hasPrefix:@"Gtk"] && [toType hasPrefix:@"CGTK"]) {
            // Converting from Gtk -> CGTK
            return [OFString stringWithFormat:@"[[%@ alloc] initWithGObject:(GObject *)%@]", [toType substringWithRange:of_range(0, [toType length] - 1)], name];
        } else if ([fromType hasPrefix:@"CGTK"] && [toType hasPrefix:@"Gtk"]) {
            // Converting from CGTK -> Gtk
            return [OFString stringWithFormat:@"[%@ %@]", name, [[toType substringWithRange:of_range(3, [toType length] - 4)] uppercaseString]];
        } else {
            return name;
        }
    }

    OFString * val = [outerDict objectForKey:toType];

    if (val == nil) {
        return name;
    } else {
        return [OFString stringWithFormat:val, name];
    }
} /* convertType */

+ (id) globalConfigValueFor:(OFString *)key {
    if (dictGlobalConf == nil) {
        dictGlobalConf = [[OFString stringWithContentsOfFile:@"Config/global_conf.map"] JSONValue]; // [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/global_conf.map"];
    }

    return [dictGlobalConf objectForKey:key];
}

+ (OFArray *) extraImports:(OFString *)clazz {
    if (dictExtraImports == nil) {
        dictExtraImports = [[OFString stringWithContentsOfFile:@"Config/extra_imports.map"] JSONValue]; // [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_imports.map"];
    }

    return [dictExtraImports objectForKey:clazz];
}

+ (OFDictionary *) extraMethods:(OFString *)clazz {
    if (dictExtraMethods == nil) {
        dictExtraMethods = [[OFString stringWithContentsOfFile:@"Config/extra_methods.map"] JSONValue];     // [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_methods.map"];

    }

    return [dictExtraMethods objectForKey:clazz];
}

@end
