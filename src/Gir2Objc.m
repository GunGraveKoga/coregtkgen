/*
 * Gir2Objc.h
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

#import "Gir2Objc.h"

#include <wctype.h>
#include <wchar.h>

@implementation Gir2Objc

+ (BOOL) parseGirFromFile:(OFString *)girFile intoDictionary:(OFDictionary **)girDict withError:(id *)parseError {
    *girDict = nil;
    *parseError = nil;

    OFString * girContents = [[OFString alloc] initWithContentsOfFile:girFile];

    if (girContents == nil) {
        of_log(@"Could not load gir contents!");
        return NO;
    }

    // Parse the XML into a dictionary
    *girDict = [XMLReader dictionaryForXMLString:girContents error:parseError];

    if (*parseError != nil) {
        // On error, if a dictionary was still created, clean it up before returning
        if (*girDict != nil) {
            [*girDict release];
        }

        return NO;
    }

    return YES;
} /* parseGirFromFile */

+ (GIRApi *) firstApiFromDictionary:(OFDictionary *)girDict {
    if (girDict == nil) {
        return nil;
    }

    for (OFString * key in girDict) {
        id value = [girDict objectForKey:key];

        if ([key isEqual:@"api"] || [key isEqual:@"repository"]) {
            return [[[GIRApi alloc] initWithDictionary:value] autorelease];
        } else if ([value isKindOfClass:[OFDictionary class]]) {
            return [Gir2Objc firstApiFromDictionary:value];
        }
    }

    return nil;
}

+ (GIRApi *) firstApiFromGirFile:(OFString *)girFile withError:(id *)parseError {
    OFDictionary * girDict = nil;

    *parseError = nil;

    if (![Gir2Objc parseGirFromFile:girFile intoDictionary:&girDict withError:parseError]) {
        return nil;
    }
    
    return [Gir2Objc firstApiFromDictionary:girDict];
}

+ (BOOL) generateClassFilesFromApi:(GIRApi *)api {
    // @try
    // {
    if (api == nil) {
        return NO;
    }

    OFArray * namespaces = api.namespaces;
    if (namespaces == nil) {
        return NO;
    }

    for (GIRNamespace * ns in namespaces) {
        if (![Gir2Objc generateClassFilesFromNamespace:ns]) {
            return NO;
        }
    }

    return YES;
    /* }
     * @catch (OFException * e)
     * {
     *   of_log(@"Exception: %@", e);
     *   return NO;
     * }*/
} /* generateClassFilesFromApi */

+ (BOOL) generateClassFilesFromNamespace:(GIRNamespace *)namespace {
    size_t i = 0;

    if (namespace == nil) {
        return NO;
    }

    OFArray * classesToGen = [CGTKUtil globalConfigValueFor:@"classesToGen"];

    // Pre-load arrTrimMethodName (in GTKUtil) from info in classesToGen
    // In order to do this we must convert from something like
    // ScaleButton to gtk_scale_button
    for (OFString * clazz in classesToGen) {
        OFMutableString * result = [[OFMutableString alloc] init];

        for (i = 0; i < [clazz length]; i++) {
            // Current character
            OFString * currentChar = [clazz substringWithRange:of_range(i, 1)];

            if (i != 0 && iswupper([currentChar characterAtIndex:0])) {
                [result appendFormat:@"_%@", [currentChar lowercaseString]];
            } else {
                [result appendString:[currentChar lowercaseString]];
            }
        }

        [CGTKUtil addToTrimMethodName:[OFString stringWithFormat:@"gtk_%@", result]];
    }

    for (GIRClass * clazz in namespace.classes) {
        if (![classesToGen containsObject:clazz.name]) {
            continue;
        }

        CGTKClass * cgtkClass = [[CGTKClass alloc] init];

        // Set basic class properties
        [cgtkClass setCName:clazz.name];
        [cgtkClass setCType:clazz.cType];
        [cgtkClass setCParentType:clazz.parent];

        // Set constructors
        for (GIRConstructor * ctor in clazz.constructors) {
            BOOL foundVarArgs = NO;

            // First need to check for varargs in list of parameters
            for (GIRParameter * param in ctor.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = YES;
                    break;
                }
            }

            // Don't handle VarArgs constructors
            if (!foundVarArgs) {
                CGTKMethod * objcCtor = [[CGTKMethod alloc] init];
                [objcCtor setCName:ctor.cIdentifier];
                [objcCtor setCReturnType:ctor.returnValue.type.cType];

                OFMutableArray * paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter * param in ctor.parameters) {
                    CGTKParameter * objcParam = [[CGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcCtor setParameters:paramArray];
                [paramArray release];
                
                [objcCtor setDeprecated:ctor.deprecated];
                [objcCtor setDeprecatedMessage:ctor.docDeprecated.docText];

                [cgtkClass addConstructor:objcCtor];
                [objcCtor release];
            }
        }

        // Set functions
        for (GIRFunction * func in clazz.functions) {
            BOOL foundVarArgs = NO;

            // First need to check for varargs in list of parameters
            for (GIRParameter * param in func.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = YES;
                    break;
                }
            }

            if (!foundVarArgs) {
                CGTKMethod * objcFunc = [[CGTKMethod alloc] init];
                [objcFunc setCName:func.cIdentifier];

                if (func.returnValue.type == nil && func.returnValue.array != nil) {
                    [objcFunc setCReturnType:func.returnValue.array.cType];
                } else {
                    [objcFunc setCReturnType:func.returnValue.type.cType];
                }

                OFMutableArray * paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter * param in func.parameters) {
                    CGTKParameter * objcParam = [[CGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcFunc setParameters:paramArray];
                [paramArray release];
                
                [objcFunc setDeprecated:func.deprecated];
                [objcFunc setDeprecatedMessage:func.docDeprecated.docText];

                [cgtkClass addFunction:objcFunc];
                [objcFunc release];
            }
        }

        // Set methods
        for (GIRMethod * meth in clazz.methods) {
            BOOL foundVarArgs = NO;

            // First need to check for varargs in list of parameters
            for (GIRParameter * param in meth.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = YES;
                    break;
                }
            }

            if (!foundVarArgs) {
                CGTKMethod * objcMeth = [[CGTKMethod alloc] init];
                [objcMeth setCName:meth.cIdentifier];

                if (meth.returnValue.type == nil && meth.returnValue.array != nil) {
                    [objcMeth setCReturnType:meth.returnValue.array.cType];
                } else {
                    [objcMeth setCReturnType:meth.returnValue.type.cType];
                }

                OFMutableArray * paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter * param in meth.parameters) {
                    CGTKParameter * objcParam = [[CGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcMeth setParameters:paramArray];
                [paramArray release];
                
                [objcMeth setDeprecated:meth.deprecated];
                [objcMeth setDeprecatedMessage:meth.docDeprecated.docText];

                [cgtkClass addMethod:objcMeth];
                [objcMeth release];
            }
        }

        [CGTKClassWriter generateFilesForClass:cgtkClass inDir:[CGTKUtil globalConfigValueFor:@"outputDir"]];

        [cgtkClass release];
    }

    return YES;
} /* generateClassFilesFromNamespace */

@end
