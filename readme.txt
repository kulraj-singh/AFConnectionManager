methods for making any sort of request on AFNetworking

way to see raw response in afnetworking:

open class AFURLResponseSerialization

see the following function. I have added two lines of NSLog where raw response is written. Write those lines in the same place i have put them and you can get the raw response.

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, AFURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }

    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    NSStringEncoding stringEncoding = self.stringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }

    id responseObject = nil;
    NSError *serializationError = nil;
    @autoreleasepool {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
        if (responseString && ![responseString isEqualToString:@" "]) {
            // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
            // See http://stackoverflow.com/a/12843465/157142
            data = [responseString dataUsingEncoding:NSUTF8StringEncoding];

            if (data) {
                if ([data length] > 0) {
                    responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];

//add these lines here
                    if (serializationError) {
                        NSLog(@"raw response: %@", responseString);
                    }
                } else {
//and this line
                    NSLog(@"raw response: %@", responseString);
                    return nil;
                }
            } else {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Data failed decoding as a UTF-8 string", @"AFNetworking", nil),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Could not decode string: %@", @"AFNetworking", nil), responseString]
                                           };

                serializationError = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            }
        }
    }

    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = AFJSONObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }

    if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }

    return responseObject;
}

change

we can also upload images , or get data from any other url
when the expected response is not in json (xml/plist) we can specify the format in requestFormat parameter.

Sample Usage:
we can use in our view controller

#import "AFConnectionManager.h"

@interface ViewController ()<AFConnectionDelegate> {
    AFConnectionManager *_requestManager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _requestManager = [[AFConnectionManager alloc]init];
    _requestManager.delegate = self;
    [self sendDataToServerWithTask:TASK_UPLOAD_PHOTO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WS call

- (void)sendDataToServerWithTask:(taskType)task
{
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    switch (task) {
        case TASK_GET:
        {
            [postDict setObject:@"json" forKey:@"format"];
            [_requestManager callServiceWithRequestType:TASK_GET method:METHOD_GET params:postDict urlEndPoint:@"weather.php"];
            break;
        }
            
        case TASK_POST:
        {
            [postDict setObject:@"json" forKey:@"format"];
            [_requestManager callServiceWithRequestType:TASK_POST method:METHOD_GET params:postDict urlEndPoint:@"weather.php"];
            break;
        }
            
        case TASK_OTHER:
        {
            [_requestManager getContentOfUrl:@"http://www.raywenderlich.com/wp-content/uploads/2014/01/sunny-background.png" requestType:task];
            break;
        }
            
        case TASK_UPLOAD_PHOTO:
        {
            UIImage *imgBack = [UIImage imageNamed:@"back_button"];
            [_requestManager uploadPhoto:imgBack urlEndPoint:@"uploadimage" requestType:task params:postDict imageKey:@"avatar"];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - WS response

- (void)requestFinishedWithResponse:(id)response
{
    NSNumber *requestType = [response objectForKey:kRequestType];
    switch (requestType.intValue) {
        case TASK_UPLOAD_PHOTO:
        {
            //load image from url
            break;
        }
        default:
            break;
    }
}

- (void)requestFailedWithError:(NSMutableDictionary *)errorDict
{
    NSError *error = [errorDict objectForKey:kError];
    NSLog(@"error: %@", error.localizedDescription);
}

@end
