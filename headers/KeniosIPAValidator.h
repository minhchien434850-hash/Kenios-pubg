//
//  KeniosIPAValidator.h
//  KENIOS HAX - IPA Validator
//
//  Created by KENIOS HAX Team
//  Copyright © 2026 KENIOS. All rights reserved.
//

#ifndef KeniosIPAValidator_h
#define KeniosIPAValidator_h

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KeniosIPAValidator : NSObject

+ (BOOL)validateIPAWithPath:(NSString *)ipaPath;
+ (BOOL)validateBundleID:(NSString *)bundleID;
+ (BOOL)validateSignature:(NSString *)appPath;
+ (NSString *)calculateSHA256:(NSString *)filePath;
+ (BOOL)isValidPUBGBundle:(NSString *)bundleID;

@end

#endif /* KeniosIPAValidator_h */
