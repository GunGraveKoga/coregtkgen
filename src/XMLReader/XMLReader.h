//
// XMLReader.h
// Based on Simple XML to OFDictionary Converter by Troy Brant
// Original source here http://troybrant.net/blog/2010/09/simple-xml-to-OFDictionary-converter/
//

#import <ObjFW/ObjFW.h>

@interface XMLReader : OFObject<OFXMLParserDelegate>
{
    OFMutableArray * dictionaryStack;
    OFMutableString * textInProgress;
    id * errorPointer;
}

+ (OFDictionary *)dictionaryForXMLData:(OFData *)data error:(id *)errorPointer;
+ (OFDictionary *)dictionaryForXMLString:(OFString *)string error:(id *)errorPointer;

@end

