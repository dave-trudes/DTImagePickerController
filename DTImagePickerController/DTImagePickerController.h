// DTImagePickerController.h
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
#import "DTCaptureView.h"
#import "DTImagePickerControlBar.h"

@protocol DTImagePickerControllerDelegate;


@interface DTImagePickerController : UIViewController
	<UIImagePickerControllerDelegate, UINavigationControllerDelegate, DTCaptureViewDelegate>

//Feature detection
@property (readonly) BOOL hasRearCamera, hasFrontCamera;
@property (readonly) BOOL hasFlash;

//If setted to YES, the status bar will disappear when the imagepicker becomes visible
@property (nonatomic, assign) BOOL showFullscreen;

@property (nonatomic, retain) IBOutlet DTCaptureView *captureView;
@property (nonatomic, retain) IBOutlet DTImagePickerControlBar *controlBar;

@property (nonatomic, assign) id<DTImagePickerControllerDelegate> delegate;

//Opens & closes the image library picker
- (IBAction)openImageLibrary;
- (IBAction)closeImageLibrary;

//Take a picture if camera is available
- (IBAction)takePicture;

//Cancel DTImagePickerController; will notify delegate for dismissing
- (void)cancel;

@end


#pragma mark - DTImagePickerControllerDelegate protocol
@protocol DTImagePickerControllerDelegate <NSObject>

@optional
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(DTImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(DTImagePickerController *)picker;

@end
#pragma mark -
