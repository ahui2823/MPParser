//
//  main.m
//  MPParser
//
//  Created by hth on 23/10/2016.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
        NSString       *file      = [arguments stringForKey:@"f"];
        NSString       *keyPath   = [arguments stringForKey:@"o"];
        NSString       *option    = [keyPath lowercaseString];

        if (file == nil || option == nil) {
            printf("\033[1mUsage:\033[0m\n"
                   "\t\033[1m%1$s\033[0m -f \033[4mfileName\033[0m -o [appid|type|uuid|ti|tn|devices|enddate|name|plist|\033[1mKeyPath\033[0m]\n\n"
                   "\n\033[1mExplaination:\033[0m\n"
                   "\t\033[1mKeyPath:\033[0m exact keypath in plist, such like \033[4mTeamName\033[0m, \033[4mEntitlements.application-identifier\033[0m and so on.\n", argv[0]);
            return 1001;
        }

        CMSDecoderRef decoderRef   = NULL;
        CFDataRef     dataRef      = NULL;
        NSString      *plistString = nil;
        NSDictionary  *plist       = nil;

        @try {
            CMSDecoderCreate(&decoderRef);
            NSData *fileData = [NSData dataWithContentsOfFile:file];
            CMSDecoderUpdateMessage(decoderRef, fileData.bytes, fileData.length);
            CMSDecoderFinalizeMessage(decoderRef);
            CMSDecoderCopyContent(decoderRef, &dataRef);
            plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
            plist       = [plistString propertyList];
        }@catch (NSException *exception) {
            printf("Could not decode file.\n");
        } @finally {
            if (decoderRef) CFRelease(decoderRef);
            if (dataRef) CFRelease(dataRef);
        }

        if ([option isEqualToString:@"appid"]) {
            NSString *applicationIdentifier = [plist valueForKeyPath:@"Entitlements.application-identifier"];
            NSString *prefix                = [[[plist valueForKeyPath:@"ApplicationIdentifierPrefix"] objectAtIndex:0] stringByAppendingString:@"."];
            printf("%s\n", [[applicationIdentifier stringByReplacingOccurrencesOfString:prefix withString:@""] UTF8String]);
        } else if ([option isEqualToString:@"type"]) {
            if ([plist valueForKeyPath:@"ProvisionedDevices"]) {
                if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
                    printf("debug\n");
                } else {
                    printf("ad-hoc\n");
                }
            } else if ([[plist valueForKeyPath:@"ProvisionsAllDevices"] boolValue]) {
                printf("enterprise\n");
            } else {
                printf("appstore\n");
            }
        } else if ([option isEqualToString:@"uuid"]) {
            NSString *uuid = [plist valueForKeyPath:@"UUID"];
            printf("%s\n", [uuid UTF8String]);
        } else if ([option isEqualToString:@"ti"]) {
            NSArray *teamIdentifier = [plist valueForKeyPath:@"TeamIdentifier"];
            printf("%s\n", [[teamIdentifier objectAtIndex:0] UTF8String]);
        } else if ([option isEqualToString:@"tn"]) {
            NSString *teamName = [plist valueForKeyPath:@"TeamName"];
            printf("%s\n", [teamName UTF8String]);
        } else if ([option isEqualToString:@"devices"]) {
            NSArray *devices = [plist valueForKeyPath:@"ProvisionedDevices"];
            printf("%s\n", devices.count > 0 ? [[devices componentsJoinedByString:@"\n"] UTF8String] : "");
        } else if ([option isEqualToString:@"enddate"]) {
            NSDate *date = [plist valueForKeyPath:@"ExpirationDate"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setLocale:[NSLocale currentLocale]];
            NSString *dateStr = [formatter stringFromDate:date];
            printf("%s\n", [dateStr UTF8String]);
        } else if ([option isEqualToString:@"name"]) {
            NSString *name = [plist valueForKeyPath:@"Name"];
            printf("%s\n", [name UTF8String]);
        } else if ([option isEqualToString:@"plist"]) {
            printf("%s", [plistString UTF8String]);
        } else {
            id result = [plist valueForKeyPath:keyPath];
            if (result) {
                if ([result isKindOfClass:[NSArray class]] && [result count]) {
                    printf("%s\n", [[result componentsJoinedByString:@"\n"] UTF8String]);
                } else {
                    printf("%s\n", [[result description] UTF8String]);
                }
            }
        }
    }
    return 0;
}
