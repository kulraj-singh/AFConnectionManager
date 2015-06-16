methods for making any sort of request on AFNetworking

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
