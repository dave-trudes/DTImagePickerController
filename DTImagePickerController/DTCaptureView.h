// DTCaptureView.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - DTCaptureViewDelegate protocol
@protocol DTCaptureViewDelegate <NSObject>

@optional
//Will be called when image capturing finishes. Dictionary mediaInfo mimics
//the dictionary passed to UIImagePickerControllerDelegate
- (void)captureViewDidFinishCaptureImageWithInfo:(NSDictionary *)mediaInfo;

//Called if an error appears during image capturing
- (void)captureViewDidFailCaptureImageWithError:(NSError *)error;
@end
#pragma mark -


@interface DTCaptureView : UIView

//AV* related settings accessors
@property (nonatomic) AVCaptureFocusMode focusMode;
@property (nonatomic) AVCaptureFlashMode flashMode;
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic) AVCaptureVideoOrientation orientation;
@property (nonatomic) AVCaptureDevicePosition devicePosition;

@property (nonatomic, readonly)	AVCaptureDevice	*device;
@property (nonatomic, readonly) AVCaptureConnection *connection;

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, assign) id<DTCaptureViewDelegate> delegate;

//Starts camera session with 'AVCaptureSessionPresetPhoto'
- (void)startCamera;
- (void)startCameraWithPreset:(NSString *)preset;
- (void)stopCamera;

//Swap the camera position if supported by device (Rear camera / Front camera)
- (void)swapCameraPosition;

//Captures the image and notifies the delegate
- (void)captureImage;

@end
