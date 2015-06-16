//
//  AFConnectionManager.h
//  dummy
//
//  Created by Kulraj Singh on 16/06/15.
// methods for using AFnetworking

//please go through the readme

#define kResponseObject @"response_object"
#define kError @"error"
#define kRequestType @"requestType"

//for different response formats
typedef enum {
    RESPONSE_JSON,
    RESPONSE_XML,
    RESPONSE_PLIST
}responseType;

typedef enum {
    TASK_GET = 200,
    TASK_POST,
    TASK_OTHER,
    TASK_UPLOAD_PHOTO
}taskType;

typedef enum {
    METHOD_GET,
    METHOD_POST,
    METHOD_PUT,
    METHOD_PATCH,
    METHOD_DELETE
} serviceMethod;

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@protocol AFConnectionDelegate <NSObject>

@required
- (void)requestFinishedWithResponse:(id)response;
- (void)requestFailedWithError:(NSMutableDictionary*)errorDict;

@end

@interface AFConnectionManager : NSObject

//Upload a foto
- (void)uploadPhoto:(UIImage*)image urlEndPoint:(NSString*)endPoint requestType:(taskType)requestType params:(NSMutableDictionary*)parameters imageKey:(NSString*)imageKey;

- (void)uploadPhoto:(UIImage*)image urlEndPoint:(NSString*)endPoint requestType:(taskType)requestType params:(NSMutableDictionary*)parameters imageKey:(NSString*)imageKey responseFormat:(responseType)responseFormat;

//call any get/post/put/patch/delete service
- (void)callServiceWithRequestType:(taskType)requestType method:(serviceMethod)method params:(NSMutableDictionary*)params urlEndPoint:(NSString*)endPoint;

//default response type is json but for xml and plist we can specify with another parameter
- (void)callServiceWithRequestType:(taskType)requestType method:(serviceMethod)method params:(NSMutableDictionary*)params urlEndPoint:(NSString*)endPoint responseFormat:(responseType)responseFormat;

//any secondary url
- (void)getContentOfUrl:(NSString*)url requestType:(taskType)requestType;

- (void)getContentOfUrl:(NSString*)url requestType:(taskType)requestType responseFormat:(responseType)responseFormat;

@property (strong, nonatomic) id<AFConnectionDelegate> delegate;

@end
