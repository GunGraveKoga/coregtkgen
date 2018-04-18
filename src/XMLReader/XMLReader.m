//
// XMLReader.m
// Based on Simple XML to OFDictionary Converter by Troy Brant
// Original source here http://troybrant.net/blog/2010/09/simple-xml-to-OFDictionary-converter/
//

#import "XMLReader.h"

@interface OFXMLParser (Namespaces)
- (OFArray<OFDictionary<OFString *, OFString *> *> *) namespaces;
@end

@implementation OFXMLParser (Namespaces)
- (OFArray<OFDictionary<OFString *, OFString *> *> *) namespaces {
    return self->_namespaces;
}
@end

OFString * const kXMLReaderTextNodeKey = @"text";

@interface XMLReader (Internal)

- (id) initWithError:(id *)error;
- (OFDictionary *) objectWithData:(OFData *)data;

@end

@implementation XMLReader

#pragma mark -
#pragma mark Public methods

+ (OFDictionary *) dictionaryForXMLData:(OFData *)data error:(id *)error {
    XMLReader * reader = [[XMLReader alloc] initWithError:error];
    OFDictionary * rootDictionary = [reader objectWithData:data];

    [reader release];
    return rootDictionary;
}

+ (OFDictionary *) dictionaryForXMLString:(OFString *)string error:(id *)error {
    OFMutableData * data = [OFMutableData data];

    [data addItems:string.UTF8String count:string.UTF8StringLength];
    
    [data makeImmutable];

    return [XMLReader dictionaryForXMLData:data error:error];
}

#pragma mark -
#pragma mark Parsing

- (id) initWithError:(id *)error {
    self = [super init];

    if (self) {
        errorPointer = error;
    }
    return self;
}

- (void) dealloc {
    [dictionaryStack release];
    [textInProgress release];
    [super dealloc];
}

- (OFDictionary *) objectWithData:(OFData *)data {
    // Clear out any old data
    [dictionaryStack release];
    [textInProgress release];

    dictionaryStack = [[OFMutableArray alloc] init];
    textInProgress = [[OFMutableString alloc] init];

    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[OFMutableDictionary dictionary]];

    // Parse the XML
    OFXMLParser * parser = [OFXMLParser parser];
    parser.delegate = self;
    [parser parseBuffer:data.items length:(data.itemSize * data.count)];
    BOOL success = [parser hasFinishedParsing];

    // Return the stack’s root dictionary on success
    if (success) {
        OFDictionary * resultDict = [dictionaryStack objectAtIndex:0];
        return resultDict;
    }

    return nil;
} /* objectWithData */

#pragma mark -
#pragma mark OFXMLParserDelegate methods

- (void) parser:(OFXMLParser *)parser didStartElement:(OFString *)element prefix:(OFString *)prefix namespace:(OFString *)aNamespace attributes:(OFArray<OFXMLAttribute *> *)attributes {
// - (void) parser:(OFXMLParser *)parser didStartElement:(OFString *)elementName namespaceURI:(OFString *)namespaceURI qualifiedName:(OFString *)qName attributes:(OFDictionary *)attributeDict {

    (void)prefix;
    (void)aNamespace;
    // Get the dictionary for the current level in the stack
    OFMutableDictionary * parentDict = [dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    OFMutableDictionary * childDict = [OFMutableDictionary dictionary];

    for (OFXMLAttribute * attribute in attributes) {
        OFString * key;
        if (attribute.namespace != nil) {
            for (OFDictionary * namespace_ in parser.namespaces) {
                for (OFString * key_ in namespace_) {
                    if (key_.length > 0) {
                        OFString * nsName = namespace_[key_];

                        if ([nsName isEqual:attribute.namespace]) {
                            key = [OFString stringWithFormat:@"%@:%@", key_, attribute.name];
                            break;
                        }
                    }
                }
            }
        } else {
            key = attribute.name;
        }
        childDict[key] = attribute.stringValue;
    }

    // [childDict addEntriesFromDictionary:attributeDict];

    // If there’s already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:element];
    if (existingValue) {
        OFMutableArray * array = nil;
        if ([existingValue isKindOfClass:[OFMutableArray class]]) {
            // The array exists, so use it
            array = (OFMutableArray *)existingValue;
        } else {
            // Create an array if it doesn’t exist
            array = [OFMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:element];
        }

        // Add the new child dictionary to the array
        [array addObject:childDict];
    } else {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:element];
    }

    // Update the stack
    [dictionaryStack addObject:childDict];
} /* parser */

- (void) parser:(OFXMLParser *)parser didEndElement:(OFString *)element prefix:(OFString *)prefix namespace:(OFString *)aNamespace {
// - (void) parser:(OFXMLParser *)parser didEndElement:(OFString *)elementName namespaceURI:(OFString *)namespaceURI qualifiedName:(OFString *)qName {
    // Update the parent dict with text info
    (void)parser;
    (void)element;
    (void)prefix;
    (void)aNamespace;
    OFMutableDictionary * dictInProgress = [dictionaryStack lastObject];

    // Set the text property
    if ([textInProgress length] > 0) {
        // Get rid of leading + trailing whitespace
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];

        // Reset the text
        [textInProgress release];
        textInProgress = [[OFMutableString alloc] init];
    }

    // Pop the current dict
    [dictionaryStack removeLastObject];
} /* parser */

- (void) parser:(OFXMLParser *)parser foundCharacters:(OFString *)string {
    (void)parser;
    // Build the text value
    [textInProgress appendString:string];
}

- (void) parser:(OFXMLParser *)parser parseErrorOccurred:(id)parseError {
    (void)parser;
    // Set the error pointer to the parser’s error object
    *errorPointer = parseError;
}

@end

