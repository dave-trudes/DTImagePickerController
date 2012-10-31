// DTCaptureView.m
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

#import "DTCaptureView.h"
#import <MobileCoreServices/MobileCoreServices.h> 
#import "DTCaptureViewUtils.h"


@implementation DTCaptureView {
	
	BOOL _isCameraRunning;
	AVCaptureDeviceInput *_currentInput;
}


#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	//Setting defaults
	self.focusMode = AVCaptureFocusModeAutoFocus;
	self.flashMode = AVCaptureFlashModeAuto;
	self.devicePosition = AVCaptureDevicePositionBack;
	
	//Create input device
	_currentInput = [DTCaptureViewUtils deviceInputWithPosition:_devicePosition];
}

#pragma mark - Settings
- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{	
	AVCaptureDevice *device = self.device;
	
	if ([device isFocusModeSupported:focusMode]) {
		NSError *error = nil;
		
		if ([device lockForConfiguration:&error]){
			device.focusMode = focusMode;
			[device unlockForConfiguration];
			_focusMode = focusMode;
		} else {
			DLog(@"Setting focusMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
	AVCaptureDevice *device = self.device;
	
	if ([device isFlashModeSupported:flashMode]) {
		NSError *error = nil;
		
		if ([device lockForConfiguration:&error]) {
			device.flashMode = flashMode;
			[device unlockForConfiguration];
			_flashMode = flashMode;
		} else {
			DLog(@"Setting flashMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
	AVCaptureDevice *device = self.device;
	if ([device isWhiteBalanceModeSupported:whiteBalanceMode]) {
		NSError *error = nil;
		
		if ([device lockForConfiguration:&error]) {
			device.whiteBalanceMode = whiteBalanceMode;
			[device unlockForConfiguration];
			_whiteBalanceMode = whiteBalanceMode;
		} else {
			DLog(@"Setting whiteBalanceMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation
{
	AVCaptureConnection *conn = self.connection;
	
	if ([conn isVideoOrientationSupported]) {
		conn.videoOrientation = orientation;
	}
}

- (void)setDevicePosition:(AVCaptureDevicePosition)devicePosition
{
	//Save new position
	_devicePosition = devicePosition;
	if (!_session) return;
	
	//Get input with given position
	AVCaptureDeviceInput *newInput = [DTCaptureViewUtils deviceInputWithPosition:devicePosition];
	
	//beginConfiguration ensures that pending changes are not applied immediately
	[_session beginConfiguration];
	[_session removeInput:_currentInput];
	[_session addInput:newInput];
	[_session commitConfiguration];
	
	_currentInput = newInput;
	
}

#pragma mark - Getter 
- (AVCaptureDevice *)device
{
	return _currentInput.device;
}

- (AVCaptureConnection *)connection
{
	return [DTCaptureViewUtils connectionWithMediaType:AVMediaTypeVideo
									   fromConnections:_stillImageOutput.connections];
}

#pragma mark - Public methods
- (void)startCamera
{
	if (_isCameraRunning) return;
	
	//Setup capture session
	[self setupCaptureSession];
	
	//Preview layer
	_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	_previewLayer.frame = self.bounds;
	_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.layer addSublayer:_previewLayer];
	
	_isCameraRunning = NO;
}

- (void)stopCamera
{
	if (!_isCameraRunning) return;
	
	[_session stopRunning];
	[_previewLayer removeFromSuperlayer];
	
	_session = nil;
	_previewLayer = nil;
	_stillImageOutput = nil;
	
	_isCameraRunning = NO;
}

- (void)swapCameraPosition
{
	self.devicePosition = (_devicePosition == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)captureImage
{
	if (!_session) return;
	
	AVCaptureConnection *conn = self.connection;
	
	//set orientation
	self.orientation = [UIDevice currentDevice].orientation;
	
	//Capture image
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:conn
												   completionHandler:^(CMSampleBufferRef imageBuffer, NSError *error)
	{
		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageBuffer];
		UIImage *image = [[UIImage alloc] initWithData:imageData];
		
		//Sending info dictionary to delegate
		NSDictionary *imageInfo = @{
			UIImagePickerControllerMediaType : (NSString *)kUTTypeImage,
			UIImagePickerControllerOriginalImage : image
		};
		[self.delegate captureViewDidFinishCaptureImage:imageInfo];
	}];
}

#pragma mark - Capture session methods
- (void)setupCaptureSession
{
	//Create session & add input
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[session addInput:_currentInput];
	
	//Create & configure output -> StillImage
	AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
	output.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
	[session addOutput:output];
	
	//Start session
	[session startRunning];
	
	_session = session;
	_stillImageOutput = output;
}


@end
