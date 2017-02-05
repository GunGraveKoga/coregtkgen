/*
 * main.h
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
#import "Gir2Objc.h"

@interface coregtkgen : OFObject<OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(coregtkgen)

@implementation coregtkgen

- (void) applicationDidFinishLaunching {
    OFString * girFile = [CGTKUtil globalConfigValueFor:@"girFile"];

#if defined(OF_WINDOWS)
    OFString * msys = ([OFApplication environment])[@"MSYSTEM_PREFIX"];

    if (msys == nil) {
        of_log(@"Invalid MSYSTEM_PREFIX env!");
        [OFApplication terminateWithStatus:1];
    }

    girFile = ([msys stringByAppendingPathComponent:girFile]).stringByStandardizingPath;
#else
    girFile = ([@"/usr/" stringByAppendingPathComponent:girFile]).stringByStandardizingPath;
#endif

    id parseError = nil;

    of_log(@"Attempting to parse GIR file...");
    GIRApi * api = [Gir2Objc firstApiFromGirFile:girFile withError:&parseError];

    if (api == nil) {
        // Check if it failed due to a parsing error
        if (parseError != nil) {
            of_log(@"Failed to parse GIR file!");
            of_log(@"%@", parseError);
        }
        // If there wasn't a file parsing error then it failed turning the OFDictionary into the GIRApi
        else {
            of_log(@"Failed to convert dictionary into GIRApi!");
        }
    } else {
        of_log(@"Finished converting dictionary into GIRApi.");
    }

    if (api != nil) {
        /*
         * Step 2: generate CoreGTK source files
         */

        of_log(@"Attempting to generate CoreGTK...");
        [Gir2Objc generateClassFilesFromApi:api];
        of_log(@"Process complete");

        /*
         * Step 3: copy CoreGTK base files
         */

        OFString * baseClassPath = [CGTKUtil globalConfigValueFor:@"baseClassDir"];
        OFString * outputDir = [CGTKUtil globalConfigValueFor:@"outputDir"];

        if (baseClassPath != nil && outputDir != nil) {
            of_log(@"Attempting to copy CoreGTK base class files...");
            OFFileManager * fileMgr = [OFFileManager defaultManager];

            // if ([fileMgr isReadableFileAtPath:baseClassPath] && [fileMgr isWritableFileAtPath:outputDir]) {
            if (true) {
                id error = nil;
                OFArray * srcDirContents = [fileMgr contentsOfDirectoryAtPath:baseClassPath];

                if (error != nil) {
                    of_log(@"Error: %@", error);
                } else {
                    for (OFString * srcFile in srcDirContents) {
                        OFString * src = [baseClassPath stringByAppendingPathComponent:[srcFile lastPathComponent]];
                        OFString * dest = [outputDir stringByAppendingPathComponent:
                                           [srcFile lastPathComponent]];

                        if ([fileMgr fileExistsAtPath:dest]) {
                            of_log(@"File [%@] already exists in destination [%@]. Removing existing file...", src, dest);
                            [fileMgr removeItemAtPath:dest];
                        }

                        of_log(@"Copying file [%@] to [%@]...", src, dest);
                        [fileMgr copyItemAtPath:src toPath:dest];
                    }
                }
            } else {
                of_log(@"Cannot read/write from directories!");
            }
            of_log(@"Process complete");
        }

        // Release memory
        [baseClassPath release];
        [outputDir release];
    }

    [OFApplication terminate];
} /* applicationDidFinishLaunching */

@end
