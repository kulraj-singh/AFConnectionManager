//
//  AFConnectionManager.m
//  dummy
//
//  Created by Kulraj Singh on 16/06/15.
//

#import "AFConnectionManager.h"
#import "UIImage+ImageManipulations.h"
#import "AFHTTPRequestOperation.h"

@interface AFConnectionManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation AFConnectionManager

- (id)init
{
    self = [super init];
    if (self) {
        //any custom initialization
    }
    return self;
}

- (AFHTTPSessionManager*)sessionManagerForResponseFormat:(responseType)responseFormat requestType:(taskType)requestType
{
    NSURL *baseURL = [NSURL URLWithString:kBaseUrl];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    switch (responseFormat) {
        case RESPONSE_JSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
            
        case RESPONSE_XML:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
            
        case RESPONSE_PLIST:
            manager.responseSerializer = [AFPropertyListResponseSerializer serializer];
            break;
            
        default:
            break;
    }
    return manager;
}

#pragma mark - call service

- (void)callServiceWithRequestType:(taskType)requestType method:(serviceMethod)method params:(NSMutableDictionary *)params urlEndPoint:(NSString *)endPoint
{
    //default format will be json
    [self callServiceWithRequestType:requestType method:method params:params urlEndPoint:endPoint responseFormat:RESPONSE_JSON];
}

- (void)callServiceWithRequestType:(taskType)requestType method:(serviceMethod)method params:(NSMutableDictionary *)params urlEndPoint:(NSString *)endPoint responseFormat:(responseType)responseFormat
{
    //any response format including plist
    _sessionManager = [self sessionManagerForResponseFormat:responseFormat requestType:requestType];
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //change base url on case basis, if need be
    
    switch (method) {
        case METHOD_GET:
        {
            [_sessionManager GET:endPoint parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestFinishedWithResponse:responseObject requestType:requestType];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailedWithError:error requestType:requestType];
            }];
            break;
        }
            
        case METHOD_POST:
        {
            [_sessionManager POST:endPoint parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestFinishedWithResponse:responseObject requestType:requestType];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailedWithError:error requestType:requestType];
            }];
            break;
        }
            
        case METHOD_DELETE:
        {
            [_sessionManager DELETE:endPoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestFinishedWithResponse:responseObject requestType:requestType];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailedWithError:error requestType:requestType];
            }];
            break;
        }
            
        case METHOD_PATCH:
        {
            [_sessionManager PATCH:endPoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestFinishedWithResponse:responseObject requestType:requestType];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailedWithError:error requestType:requestType];
            }];
            break;
        }
            
        case METHOD_PUT:
        {
            [_sessionManager PUT:endPoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestFinishedWithResponse:responseObject requestType:requestType];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailedWithError:error requestType:requestType];
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - video

- (void)uploadVideoWithLocalUrl:(NSURL *)videoUrl urlEndPoint:(NSString *)endPoint requestType:(taskType)requestType params:(NSMutableDictionary *)postDict videoKey:(NSString *)videoKey imageKey:(NSString *)imageKey
{
    _sessionManager = [self sessionManagerForResponseFormat:RESPONSE_JSON requestType:requestType];
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    UIImage *thumbnail = [UIImage videoSnapshotFromUrl:videoUrl];
    NSData *imgData = UIImagePNGRepresentation(thumbnail);
    
    [_sessionManager POST:endPoint parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imgData name:imageKey fileName:@"image.png" mimeType:@"image/png"];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [formData appendPartWithFileData:videoData name:@"video" fileName:@"video.mov" mimeType:@"video/quicktime"];
    }
      progress:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
        [self requestFinishedWithResponse:responseObject requestType:requestType];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailedWithError:error requestType:requestType];
    }];
}

#pragma mark - photo

- (void)uploadPhoto:(UIImage *)image urlEndPoint:(NSString *)endPoint requestType:(taskType)requestType params:(NSMutableDictionary *)parameters imageKey:(NSString *)imageKey
{
    [self uploadPhoto:image urlEndPoint:endPoint requestType:requestType params:parameters imageKey:imageKey responseFormat:RESPONSE_JSON];
}

- (void)uploadPhoto:(UIImage*)image urlEndPoint:(NSString*)endPoint requestType:(taskType)requestType params:(NSMutableDictionary*)parameters imageKey:(NSString*)imageKey responseFormat:(responseType)responseFormat
{
    _sessionManager = [self sessionManagerForResponseFormat:responseFormat requestType:requestType];
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    image = [image fixrotation];
    
    NSData *imageData = UIImagePNGRepresentation(image);
//    NSInteger imageSize = imageData.length;
//    
//    //limit image size to 100 kb
//    float maxSize = 100000; //100 kb
//    if (imageSize > maxSize) {
//        float compressionFactor = maxSize/imageSize;
//        imageData = (UIImageJPEGRepresentation(image, compressionFactor));
//    }  
    
    [_sessionManager POST:endPoint parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:imageKey fileName:@"image.png" mimeType:@"image/png"];
    } progress:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
        [self requestFinishedWithResponse:responseObject requestType:requestType];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailedWithError:error requestType:requestType];
    }];
}

- (void)uploadPhoto:(UIImage*)image secondPhoto:(UIImage *)secondImage urlEndPoint:(NSString *)endPoint requestType:(taskType)requestType params:(NSMutableDictionary *)parameters imageKey:(NSString *)imageKey secondImageKey:(NSString *)secondImageKey
{
    _sessionManager = [self sessionManagerForResponseFormat:RESPONSE_JSON requestType:requestType];
    _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    //limit image size to 100 kb
    float maxSize = 100000; //100 kb
    
    NSData *imageData;
    if (image) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
        NSInteger imageSize = imageData.length;
        
        if (imageSize > maxSize) {
            float compressionFactor = maxSize/imageSize;
            imageData = UIImageJPEGRepresentation(image, compressionFactor);
        }
    }
    
    NSData *secondImageData;
    if (secondImage) {
        
        secondImageData = UIImageJPEGRepresentation(secondImage, 1.0);
        NSInteger secondImageSize = secondImageData.length;
        
        if (secondImageSize > maxSize) {
            float compressionFactor = maxSize/secondImageSize;
            secondImageData = UIImageJPEGRepresentation(secondImage, compressionFactor);
        }
    }
    
    [_sessionManager POST:endPoint parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        if (image) {
            [formData appendPartWithFileData:imageData name:imageKey fileName:@"frontImage.jpg" mimeType:@"image/jpeg"];
        }
        
        if (secondImage) {
            [formData appendPartWithFileData:secondImageData name:secondImageKey fileName:@"backImage.jpg" mimeType:@"image/jpeg"];
        }
    }
      progress:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
        [self requestFinishedWithResponse:responseObject requestType:requestType];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailedWithError:error requestType:requestType];
    }];
}

#pragma mark - ad hoc get request

- (void)getContentOfUrl:(NSString *)url requestType:(taskType)requestType
{
    [self getContentOfUrl:url requestType:requestType responseFormat:RESPONSE_JSON];
}

- (void)getContentOfUrl:(NSString *)urlString requestType:(taskType)requestType responseFormat:(responseType)responseFormat
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self requestFinishedWithResponse:responseObject requestType:requestType];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self requestFailedWithError:error requestType:requestType];
    }];
}

#pragma mark - cancel request

- (void)cancelAllRequests
{
    [_sessionManager.operationQueue cancelAllOperations];
}

#pragma mark - delegates

- (void)requestFinishedWithResponse:(id)response requestType:(taskType)requestType
{
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc]init];
    [responseDict setObject:response forKey:kResponseObject];
    NSNumber *tag = [NSNumber numberWithInt:requestType];
    [responseDict setObject:tag forKey:kRequestType];
    
    [self.delegate performSelector:@selector(requestFinishedWithResponse:) withObject:responseDict];
}

- (void)requestFailedWithError:(NSError*)error requestType:(taskType)requestType
{
    NSString *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    NSLog(@"response: %@", response);
    
    NSMutableDictionary *errorDict = [[NSMutableDictionary alloc]init];
    [errorDict setObject:error forKey:kError];
    NSNumber *tag = [NSNumber numberWithInt:requestType];
    [errorDict setObject:tag forKey:kRequestType];
    
    [self.delegate performSelector:@selector(requestFailedWithError:) withObject:errorDict];
}

@end
