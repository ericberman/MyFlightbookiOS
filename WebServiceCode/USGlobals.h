#import <Foundation/Foundation.h>

@interface USGlobals : NSObject {
	NSMutableDictionary *wsdlStandardNamespaces;
}

@property (nonatomic, strong) NSMutableDictionary *wsdlStandardNamespaces;

+ (USGlobals *)sharedInstance;

@end
