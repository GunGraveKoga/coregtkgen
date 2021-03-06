/*
 * CGTKClassWriter.m
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
#import <ObjFW/ObjFW.h>

#import "Generator/CGTKClassWriter.h"

@implementation CGTKClassWriter

+ (void) generateFilesForClass:(CGTKClass *)cgtkClass inDir:(OFString *)outputDir {
    id error = nil;

    OFFileManager * fileManager = [OFFileManager defaultManager];

    if (![fileManager directoryExistsAtPath:outputDir]) {
        [fileManager createDirectoryAtPath:outputDir createParents:YES];
    }

    // Header
    OFString * hFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingString:@".h"];

    [[CGTKClassWriter headerStringFor:cgtkClass] writeToFile:hFilename];

    if (error != nil) {
        of_log(@"Error writing header file: %@", error);
        error = nil;
    }

    // Source
    OFString * sFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingString:@".m"];

    [[CGTKClassWriter sourceStringFor:cgtkClass] writeToFile:sFilename];

    if (error != nil) {
        of_log(@"Error writing source file: %@", error);
        error = nil;
    }
} /* generateFilesForClass */

+ (OFString *) headerStringFor:(CGTKClass *)cgtkClass {
    OFMutableString * output = [[OFMutableString alloc] init];

    of_log(@"Class %@", cgtkClass.cName);

    [output appendString:[CGTKClassWriter generateLicense:[OFString stringWithFormat:@"%@.h", [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"CoreGTK/%@.h\"\n", [CGTKUtil swapTypes:[cgtkClass cParentType]]];

    OFArray * extraImports = [CGTKUtil extraImports:[cgtkClass type]];

    if (extraImports != nil) {
        for (OFString * imp in extraImports) {
            of_log(@"%@", imp);
            [output appendFormat:@"#import %@\n", imp];
        }
    }
    
    [output appendString:@"\n"];

    // Interface declaration
    [output appendFormat:@"\nOF_ASSUME_NONNULL_BEGIN\n\n@interface %@ : %@\n{\n\n}\n\n", [cgtkClass name], [CGTKUtil swapTypes:[cgtkClass cParentType]]];

    // Function declarations
    if ([cgtkClass hasFunctions]) {
        [output appendString:@"/**\n * Functions\n */\n"];

        for (CGTKMethod * func in [cgtkClass functions]) {
            [output appendFormat:@"+ (%@)%@", [func returnType], [func sig]];
            
            if ([func isDeprecated]) {
                [output appendFormat:@" GTK_OBJC_DEPRECATED(%@)", [func deprecatedMessage]];
            }
            
            [output appendUTF8String:";\n"];
        }
    }

    if ([cgtkClass hasConstructors]) {
        [output appendString:@"\n/**\n * Constructors\n */\n"];

        // Constructor declarations
        for (CGTKMethod * ctor in [cgtkClass constructors]) {
            [output appendFormat:@"- (instancetype)%@", [CGTKUtil convertFunctionToInit:[ctor sig]]];
            
            if ([ctor isDeprecated]) {
                [output appendFormat:@" GTK_OBJC_DEPRECATED(\"%@\")", [ctor deprecatedMessage]];
            }
            
            [output appendUTF8String:";\n"];
        }
    }

    [output appendString:@"\n/**\n * Methods\n */\n\n"];

    // Self type method declaration
    [output appendFormat:@"-(%@*)%@;\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString]];

    OFDictionary * extraMethods = [CGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString * m in extraMethods) {
            [output appendFormat:@"\n%@;\n", m];
        }
    }

    for (CGTKMethod * meth in [cgtkClass methods]) {
        [output appendFormat:@"\n%@\n", [CGTKClassWriter generateDocumentationForMethod:meth]];
        [output appendFormat:@"- (%@)%@", [meth returnType], [meth sig]];
        
        if ([meth isDeprecated]) {
            [output appendFormat:@" GTK_OBJC_DEPRECATED(\"%@\")", [meth deprecatedMessage]];
        }
        
        [output appendUTF8String:";\n"];
    }

    // End interface
    [output appendString:@"\n@end\n\nOF_ASSUME_NONNULL_END\n\n"];

    return [output autorelease];
} /* headerStringFor */

+ (OFString *) sourceStringFor:(CGTKClass *)cgtkClass {
    OFMutableString * output = [[OFMutableString alloc] init];

    [output appendString:[CGTKClassWriter generateLicense:[OFString stringWithFormat:@"%@.m", [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"CoreGTK/%@.h\"\n\n", [cgtkClass name]];
    [output appendUTF8String:"\t#pragma clang diagnostic push\n\t#pragma clang diagnostic ignored \"-Wdeprecated-declarations\"\n\n"];

    // Implementation declaration
    [output appendFormat:@"@implementation %@\n\n", [cgtkClass name]];

    // Function implementations
    for (CGTKMethod * func in [cgtkClass functions]) {
        [output appendFormat:@"+ (%@)%@", [func returnType], [func sig]];

        [output appendString:@"\n{\n"];

        if ([func returnsVoid]) {
            [output appendFormat:@"\t%@(%@);\n", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([CGTKUtil isTypeSwappable:[func cReturnType]]) {
                // Need to swap type on return
                [output appendString:[CGTKUtil convertType:[func cReturnType] withName:[OFString stringWithFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]] toType:[func returnType]]];
            } else {
                [output appendFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
            }

            [output appendString:@";\n"];
        }

        [output appendString:@"}\n\n"];
    }

    OFDictionary * extraMethods = [CGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString * m in extraMethods) {
            [output appendFormat:@"%@\n%@\n\n", m, [extraMethods objectForKey:m]];
        }
    }

    // Constructor implementations
    for (CGTKMethod * ctor in [cgtkClass constructors]) {
        
        [output appendFormat:@"- (instancetype)%@", [CGTKUtil convertFunctionToInit:[ctor sig]]];

        [output appendString:@"\n{\n"];

        [output appendFormat:@"\tself = %@;\n\n", [CGTKUtil getFunctionCallForConstructorOfType:[cgtkClass cType] withConstructor:[OFString stringWithFormat:@"%@(%@)", [ctor cName], [CGTKClassWriter generateCParameterListString:[ctor parameters]]]]];

        [output appendString:@"\tif(self)\n\t{\n\t\t//Do nothing\n\t}\n\n\treturn self;\n"];

        [output appendString:@"}\n\n"];
    }

    // Self type method implementation
    [output appendFormat:@"- (%@*)%@\n{\n\treturn %@;\n}\n\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString], [CGTKUtil selfTypeMethodCall:[cgtkClass cType]]];

    for (CGTKMethod * meth in [cgtkClass methods]) {
        
        [output appendFormat:@"-(%@)%@", [meth returnType], [meth sig]];

        [output appendString:@"\n{\n"];

        if ([meth returnsVoid]) {
            [output appendFormat:@"\t%@(%@);\n", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([CGTKUtil isTypeSwappable:[meth cReturnType]]) {
                // Need to swap type on return
                [output appendString:[CGTKUtil convertType:[meth cReturnType] withName:[OFString stringWithFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]] toType:[meth returnType]]];
            } else {
                [output appendFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
            }

            [output appendString:@";\n"];
        }

        [output appendString:@"}\n\n"];
    }

    // End implementation
    [output appendString:@"\n@end"];
    
    [output appendUTF8String:"\n\n\t#pragma clang diagnostic pop\n"];

    return [output autorelease];
} /* sourceStringFor */

+ (OFString *) generateCParameterListString:(OFArray *)params {
    size_t i;
    OFMutableString * paramsOutput = [[OFMutableString alloc] init];

    if (params != nil && [params count] > 0) {
        CGTKParameter * p;
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
}

+ (OFString *) generateCParameterListWithInstanceString:(OFString *)instanceType andParams:(OFArray *)params {
    size_t i;
    OFMutableString * paramsOutput = [[OFMutableString alloc] init];

    [paramsOutput appendString:[CGTKUtil selfTypeMethodCall:instanceType]];

    if (params != nil && [params count] > 0) {
        [paramsOutput appendString:@", "];

        CGTKParameter * p;

        // Start at index 1
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
} /* generateCParameterListWithInstanceString */

+ (OFString *) generateLicense:(OFString *)fileName {
    id error = nil;
    OFString * licText = [OFString stringWithContentsOfFile:@"Config/license.txt"];

    if (error == nil) {
        return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@" withString:fileName];
    } else {
        of_log(@"Error reading license file: %@", error);
        return nil;
    }
}

+ (OFString *) generateDocumentationForMethod:(CGTKMethod *)meth {
    size_t i;
    CGTKParameter * p = nil;

    OFMutableString * doc = [[OFMutableString alloc] init];

    [doc appendFormat:@"/**\n * -(%@*)%@;\n *\n", [meth returnType], [meth sig]];

    if ([meth.parameters count] > 0) {
        for (i = 0; i < [meth.parameters count]; i++) {
            p = [meth.parameters objectAtIndex:i];

            [doc appendFormat:@" * @param %@\n", [p name]];
        }
    }

    if (![meth returnsVoid]) {
        [doc appendFormat:@" * @returns %@\n", [meth returnType]];
    }

    [doc appendString:@" */"];

    return [doc autorelease];
} /* generateDocumentationForMethod */

@end
