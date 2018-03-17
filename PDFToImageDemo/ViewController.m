//
//  ViewController.m
//  PDFToImageDemo
//
//  Created by User on 3/16/18.
//  Copyright © 2018 User. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     NSString *path = [[NSBundle mainBundle] pathForResource:@"11" ofType:@"pdf"];
    [self savePdfFirstPageSnaptImageToCache:[NSURL fileURLWithPath:path]];
}

- (void)savePdfFirstPageSnaptImageToCache:(NSURL *)fileUrl {
    //获取size
    UIImage *image;
    CGRect rect = CGRectNull;
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)fileUrl);
    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    rect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);
    NSInteger rotationAngle = CGPDFPageGetRotationAngle(page1);
    if (rotationAngle == 90 || rotationAngle == 270) {
        CGFloat temp = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = temp;
    }
    CGFloat maxSize = 300;
    CGFloat tempSize = MAX(rect.size.width, rect.size.height);
    if (tempSize > maxSize) {
        if (rect.size.width > rect.size.height) {
            rect.size.height = maxSize * rect.size.height / rect.size.width;
            rect.size.width = maxSize;
        } else {
            rect.size.width = maxSize * rect.size.width / rect.size.height;
            rect.size.height = maxSize;
        }
    }
    
    if (!CGRectEqualToRect(rect, CGRectNull)) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGAffineTransform drawingTransform = CGPDFPageGetDrawingTransform(page1, kCGPDFCropBox, rect, 0, true);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(ctx, drawingTransform);
        CGContextDrawPDFPage(ctx, page1);
        image = UIGraphicsGetImageFromCurrentImageContext();
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored];
        UIGraphicsEndImageContext();
    }
    if (image) {
        NSString *fileJpgPath = [fileUrl.absoluteString stringByReplacingOccurrencesOfString:@".pdf" withString:@".jpg"];
        NSData *data = UIImageJPEGRepresentation(image, 0.9);
        if (data.length > 0) {
            [data writeToURL:[NSURL URLWithString:fileJpgPath] atomically:YES];
        }
    }
    CGPDFDocumentRelease(pdf);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
