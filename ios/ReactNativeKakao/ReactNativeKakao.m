//
//  ReactNativeKakao.m
//  ReactNativeKakao
//
//  Created by Jeff Kang on 4/24/17.
//  Copyright © 2017 Jeff Gu Kang. All rights reserved.
//

#import "ReactNativeKakao.h"

@implementation RCTConvert (KOAuthType)
RCT_ENUM_CONVERTER(KOAuthType, (@{
								  @"KOAuthTypeTalk" : @(KOAuthTypeTalk),
								  @"KOAuthTypeStory" : @(KOAuthTypeStory),
								  @"KOAuthTypeAccount" : @(KOAuthTypeAccount)
								  }), KOAuthTypeTalk, integerValue)
@end


@implementation ReactNativeKakao

RCT_EXPORT_MODULE();
+ (BOOL)requiresMainQueueSetup
{
	return YES;
}

- (NSDictionary *)constantsToExport
{
	return @{ @"KOAuthTypeTalk" : @(KOAuthTypeTalk),
			  @"KOAuthTypeStory" : @(KOAuthTypeStory),
			  @"KOAuthTypeAccount" : @(KOAuthTypeAccount) };
};

/**
 Login or Signup
 @param authTypes array consists in KOAuthType.
 */
RCT_REMAP_METHOD(loginWithAuthTypes,
				 authTypes: (NSArray* )authTypes
				 resolver:(RCTPromiseResolveBlock)resolve
				 rejecter:(RCTPromiseRejectBlock)reject)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[KOSession sharedSession] close];
		NSArray *auths = (authTypes != nil) ? authTypes : @[@(KOAuthTypeTalk), @(KOAuthTypeStory), @(KOAuthTypeAccount)];
		//		- (void)openWithCompletionHandler:(KOSessionCompletionHandler)completionHandler authTypes:(NSArray<NSNumber *> *)authTypes;
		[[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
			NSLog(@"MYLOG: openWithCompletionHandler");
			
			if(error) {
				NSLog(@"Error: %@", error.description);
				NSLog(@"%@", error.description);
				
				reject(@"RNKakao", @"login error", error);
				return;
			}
			
			if ([[KOSession sharedSession] isOpen]) {
				NSLog(@"sharedSession is open");
				
				[self userInfoRequestResolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject];
				return;
			} else {
				reject(@"RNKakao", @"login canceled", nil);
				return;
			}
		} authTypes:auths];
	});
}

/**
 Login or Signup
 */
RCT_REMAP_METHOD(login,
				 loginWithResolver:(RCTPromiseResolveBlock)resolve
				 loginWithRejecter:(RCTPromiseRejectBlock)reject)
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[KOSession sharedSession] close];
		NSArray *auths = @[@(KOAuthTypeTalk)];
		
		[[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
			NSLog(@"MYLOG: openWithCompletionHandler");
			
			if(error) {
				NSLog(@"Error: %@", error.description);
				NSLog(@"%@", error.description);
				
				reject(@"RNKakao", @"login error", error);
				return;
			}
			
			if ([[KOSession sharedSession] isOpen]) {
				NSLog(@"sharedSession is open");
				
				[self userInfoRequestResolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject];
				return;
			} else {
				reject(@"RNKakao", @"login canceled", nil);
				return;
			}
		} authTypes:auths];
	});
}

/**
 Get userInfo
 */
RCT_REMAP_METHOD(userInfo,
				 userInfoWithResolver:(RCTPromiseResolveBlock)resolve
				 userInfoWithRejecter:(RCTPromiseRejectBlock)reject)
{
	[self userInfoRequestResolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject];
}

/**
 Logout
 */
RCT_REMAP_METHOD(logout,
				 logoutWithResolver:(RCTPromiseResolveBlock)resolve
				 logoutWithRejecter:(RCTPromiseRejectBlock)reject)
{
	[[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error) {
		if (error) {
			reject(@"RNKakao", @"logout error", error);
		} else {
			NSMutableDictionary *response = [NSMutableDictionary dictionary];
			[response setValue:@"Logged out" forKey:@"success"];
			
			resolve(response);
		}
	}];
}

RCT_REMAP_METHOD(sendKakaoMessage,
                 sendParams:(NSDictionary *)sendParams
                 serverParams:(NSDictionary *)serverParams
                 sendKakaoMessageWithResolver:(RCTPromiseResolveBlock)resolve
                 sendKakaoMessageWithRejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *title = [RCTConvert NSString:sendParams[@"title"]];
    NSString *description = [RCTConvert NSString:sendParams[@"description"]];
    NSString *imageURL = [RCTConvert NSString:sendParams[@"imageURL"]];
    NSString *buttonMessage = [RCTConvert NSString:sendParams[@"buttonMessage"]];
    NSString *mobileWebURL = [RCTConvert NSString:sendParams[@"mobileWebURL"]];
    NSString *webURL = [RCTConvert NSString:sendParams[@"webURL"]];
    NSString *androidExecutionParams = [RCTConvert NSString:sendParams[@"androidExecutionParams"]];
    NSString *iosExecutionParams = [RCTConvert NSString:sendParams[@"iosExecutionParams"]];
    
    KMTLinkObject *link = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
        linkBuilder.mobileWebURL = [NSURL URLWithString:mobileWebURL];
        linkBuilder.webURL = [NSURL URLWithString:webURL];
        linkBuilder.androidExecutionParams = androidExecutionParams;
        linkBuilder.iosExecutionParams = iosExecutionParams;
    }];
    
    KMTTemplate *template = [KMTFeedTemplate feedTemplateWithBuilderBlock:^(KMTFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
        feedTemplateBuilder.content = [KMTContentObject contentObjectWithBuilderBlock:^(KMTContentBuilder * _Nonnull contentBuilder) {
            contentBuilder.title = title;
            contentBuilder.desc = description;
            contentBuilder.imageURL = [NSURL URLWithString:imageURL];
            contentBuilder.link = link;
        }];


        [feedTemplateBuilder addButton:[KMTButtonObject buttonObjectWithBuilderBlock:^(KMTButtonBuilder * _Nonnull buttonBuilder) {
            buttonBuilder.title = buttonMessage;
            buttonBuilder.link = link;
        }]];
    }];
    
    NSDictionary<NSString *, NSString *> * callbackArgs = serverParams;
    
    [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template serverCallbackArgs:callbackArgs
      success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        RCTLogInfo(@"warning message: %@", warningMsg);
        RCTLogInfo(@"argument message: %@", argumentMsg);
        RCTLogInfo(@"argument message: %@", callbackArgs);
        resolve(argumentMsg);
    } failure:^(NSError * _Nonnull error) {
        RCTLogError(@"error: %@", error);
        reject(@"RNKakao", @"sendKakaoMessage error", error);
    }];
}

/*!
 Related in user information permission: https://developers.kakao.com
 */
- (void) userInfoRequestResolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
	[KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *result) {
		if (error) {
			reject(@"RNKakao", @"userInfo error", error);
		} else if (result) {
			NSString *id = result.ID;
			NSString *nickName = result.nickname;
			NSURL *profileImage = result.profileImageURL;
			NSURL *profileImageThumnail = result.thumbnailImageURL;
			
			// Additional Info (Optional)
			KOUserMeAccount *account = result.account;
			NSString *email = account.email;
			NSString *phoneNumber = account.phoneNumber;
			NSString *displayId = account.displayID;
			
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
			[userInfo setValue:id forKey:@"id"];
			[userInfo setValue:[KOSession sharedSession].token.accessToken forKey:@"accessToken"];
			
			if (nickName) [userInfo setValue:nickName forKey:@"nickName"];
			if (email) [userInfo setValue:email forKey:@"email"];
			if (profileImage) [userInfo setValue:profileImage.absoluteString forKey:@"profileImage"];
			if (profileImageThumnail) [userInfo setValue:profileImageThumnail.absoluteString forKey:@"profileImageThumnail"];
			if (phoneNumber) [userInfo setValue:phoneNumber forKey:@"phoneNumber"];
			if (displayId) [userInfo setValue:displayId forKey:@"displayId"];
			
			resolve(userInfo);
		}
	}];
}
@end
