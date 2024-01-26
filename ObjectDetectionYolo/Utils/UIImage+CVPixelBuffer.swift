//
//  UIImage+CVPixelBuffer.swift
//  ObjectDetectionYolo
//
//  Created by Raghvender on 24/01/24.
//

import UIKit

extension UIImage {
    func pixelBufferFromImage() -> CVPixelBuffer {
        let ciImage = CIImage(image: self)
        let tmpcontext = CIContext(options: nil)
        let cgImage = tmpcontext.createCGImage(ciImage!, from: ciImage!.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
     
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
     
        let width = cgImage!.width
        let height = cgImage!.height
        
        var pxBuffer: CVPixelBuffer?
        // if pxBuffer = nil, you will get status -6641
        
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                              kCVPixelFormatType_32BGRA, options, &pxBuffer)
        status = CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0));
             
        let bufferAddress = CVPixelBufferGetBaseAddress(pxBuffer!);
             
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxBuffer!);
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        context?.draw(cgImage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
        status = CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        return pxBuffer!;
    }
}
