// DTCaptureViewUtils.m
// 
// Copyright (c) 2012 David Renoldner <hello@davetrudes.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTCaptureViewUtils.h"

@implementation DTCaptureViewUtils

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:mediaType]) {
                return connection;
            }
        }
    }
    return nil;
}


+ (AVCaptureDeviceInput *)deviceInputWithPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	
	//Find device with given position
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
			return [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
		}
    }
	
    return nil;
}

@end

#pragma mark - Functions
NSString* NSStringFromUIImageOrientation(UIImageOrientation orientation)
{
    switch (orientation) {
        case UIImageOrientationDown:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationDown", UIImageOrientationDown];
        case UIImageOrientationDownMirrored:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationDownMirrored", UIImageOrientationDownMirrored];
        case UIImageOrientationLeft:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationLeft", UIImageOrientationLeft];
        case UIImageOrientationLeftMirrored:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationLeftMirrored", UIImageOrientationLeftMirrored];
        case UIImageOrientationUp:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationUp", UIImageOrientationUp];
        case UIImageOrientationUpMirrored:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationUpMirrored", UIImageOrientationUpMirrored];
        case UIImageOrientationRight:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationRight", UIImageOrientationRight];
        case UIImageOrientationRightMirrored:
            return [NSString stringWithFormat:@"%@ [%d]", @"UIImageOrientationRightMirrored", UIImageOrientationRightMirrored];
    }
}

