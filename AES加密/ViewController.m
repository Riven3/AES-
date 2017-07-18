//
//  ViewController.m
//  AES加密
//
//  Created by Apple-Mini on 17/7/14.
//  Copyright © 2017年 qinghua. All rights reserved.
//

#import "ViewController.h"
#import "AESCrypt.h"
#import "NSString+Base64.h"
#import "AFNetworking.h"
#import <AdSupport/AdSupport.h>

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *string = @"qwertyuiop";
    NSData *data5 = [string dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *result = [self convertDataToHexStr:data5];
    NSString *result = [AESCrypt encrypt:@"1111111111111111" password:@"1234567898765432"];
    NSLog(@"%@",result);

    //NSString *string = [AESCrypt encrypt:@"1234" password:@"key"];
    
    NSString *secretKey = [self earnData];

    NSMutableData *resultData = [[NSMutableData alloc]init];
    //盐值
    NSString *randomKey = [self createArcRandomString];
    NSData *randomData = [randomKey dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *randow16 = [self convertDataToHexStr:randomData];
    //加密后的字符串
    NSString *adString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *dataString = [AESCrypt encrypt:[NSString stringWithFormat:@"pks=1105855019&aid=%@&pid=com.free.bomb",adString] password:secretKey];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *data16 = [self convertDataToHexStr:data];
    //加密key
    NSLog(@"加密前%@",secretKey);
    NSString *secret16 = [self convertDataToHexStr:[self p_obfuscateWithData:secretKey]];
    NSLog(@"加密后%@",secret16);
    NSData *secretkeyData=  [self p_obfuscateWithData:secretKey];
    
    
    
    [resultData appendData:secretkeyData];
    [resultData appendData:randomData];
    [resultData appendData:data];
    
    //NSString *resultString = [NSString stringWithFormat:@"%@%@%@",secret16,randow16,data16];
    
    //8[resultData appendData:[self p_obfuscateWithData:secretKey]];
    
    NSData *postData = [resultData copy];
    NSString *resultString1 = [self convertDataToHexStr:postData];
    NSLog(@"%@",resultString1);
    [self postAndAsynchronousMethodWithString:postData];
    
    
}




//随机盐值
- (NSString *)createArcRandomString{
    NSMutableString *string = [NSMutableString new];
    for (int i= 0 ;i < 4; i++) {
        int j = arc4random()%9;
        [string appendString:[NSString stringWithFormat:@"%d",j]];
    }
    return [string copy];
}



- (NSString *)earnData{
    NSMutableString *nAesKey  = [[NSMutableString alloc]init];
    for (int i = 0; i < 16; i ++) {
        NSString *string = [NSString stringWithFormat:@"%d",arc4random()%10];
        nAesKey = [[NSMutableString alloc]initWithFormat:@"%@%@",nAesKey,string];
    }
    NSString *AESKey = [NSString stringWithString:nAesKey];
    return AESKey;
}


- (NSData *)p_obfuscateWithData:(NSString *)dataString{
    /*
     *这里随机取出数字   加密key、
     */
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    Byte *AESbytes = (Byte *)[data bytes];
    int xor[6] = {0x32,0x78,0x65,0x23,0x54,0x44};
    //Byte* jbByte = (Byte*)malloc(100);
    NSMutableData *encryptData = [[NSMutableData alloc]init];
    //NSMutableArray *byte = [NSMutableArray array];
    for (int i = 0; i < 16; i ++) {
        int j = i % 6;
        int a = xor[j];
        int b = AESbytes[i];
        Byte c = (Byte)a ^ b;
        [encryptData appendBytes:&c length:1];
        //NSLog(@"前%@",a);
    }
    return [encryptData copy];
}




- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}


- (void)postAndAsynchronousMethodWithString:(NSData *)postdata{
    NSURL *url = [NSURL URLWithString:@"http://10.23.0.91:8080/g/t"];
    //NSData *postData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postdata;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"请求结果%@ %@",string,response);
    }];
}



/** 加密 */
/*- (NSString *)p_stringEncrypt{
    //NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *s =[self p_obfuscateWithData:[self earnData]];
    //加密之后包一层base64保证编码格式不变
    NSString *str = [s base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"%@",str);
    return str;
}*/
/*- (NSString *)d_stringEncryptWith:(NSString *)string{
    //解base64
    NSData *data =  [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSData *s1 =[self p_obfuscateWithData:data];
    //解密后是个json串
    NSString *s = [[NSString alloc] initWithData:s1 encoding:NSUTF8StringEncoding];
    return s;
}*/

// https://apis.getpictureinfo.com/g/t



@end
