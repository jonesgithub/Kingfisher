//
//  UIImageView+Kingfisher.swift
//  WebImageDemo
//
//  Created by Wei Wang on 15/4/6.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public typealias DownloadProgressBlock = ((receivedSize: Int64, totalSize: Int64) -> ())
public typealias CompletionHandler = ((image: UIImage?, error: NSError?, imageURL: NSURL) -> ())

// MARK: - Set Images
public extension UIImageView {
    /**
    Set an image with a URL.
    It will ask for Kingfisher's manager to get the image for the URL.
    The memory and disk will be searched first. If the manager does not find it, it will try to download the image at this URL and store it for next use.
    
    :param: URL The URL of image.
    
    :returns: A task represents the retriving process.
    */
    public func kf_setImageWithURL(URL: NSURL) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeHolderImage: nil, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil)
    }
    
    /**
    Set an image with a URL and a place holder image.
    
    :param: URL              The URL of image.
    :param: placeHolderImage A placeholder image when retrieving the image at URL.
    
    :returns: A task represents the retriving process.
    */
    public func kf_setImageWithURL(URL: NSURL,
                      placeHolderImage: UIImage?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeHolderImage: placeHolderImage, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil)
    }
    
    /**
    Set an image with a URL, a place holder image and options.
    
    :param: URL              The URL of image.
    :param: placeHolderImage A placeholder image when retrieving the image at URL.
    :param: options          Options which could control some behaviors. See `KingfisherOptions` for more.
    
    :returns: A task represents the retriving process.
    */
    public func kf_setImageWithURL(URL: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeHolderImage: placeHolderImage, options: options, progressBlock: nil, completionHandler: nil)
    }
    
    /**
    Set an image with a URL, a place holder image, options and completion handler.
    
    :param: URL               The URL of image.
    :param: placeHolderImage  A placeholder image when retrieving the image at URL.
    :param: options           Options which could control some behaviors. See `KingfisherOptions` for more.
    :param: completionHandler Called when the image retrieved and set.
    
    :returns: A task represents the retriving process.
    */
    public func kf_setImageWithURL(URL: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions,
                     completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(URL, placeHolderImage: placeHolderImage, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
    
    /**
    Set an image with a URL, a place holder image, options, progress handler and completion handler.
    
    :param: URL               The URL of image.
    :param: placeHolderImage  A placeholder image when retrieving the image at URL.
    :param: options           Options which could control some behaviors. See `KingfisherOptions` for more.
    :param: progressBlock     Called when the image downloading progress gets updated.
    :param: completionHandler Called when the image retrieved and set.
    
    :returns: A task represents the retriving process.
    */
    public func kf_setImageWithURL(URL: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions,
                         progressBlock: DownloadProgressBlock?,
                     completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        image = placeHolderImage
        
        self.kf_setWebURL(URL)
        let task = KingfisherManager.sharedManager.retriveImageWithURL(URL, options: options, progressBlock: { (recivedSize, totalSize) -> () in
            if let progressBlock = progressBlock {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    progressBlock(receivedSize: recivedSize, totalSize: totalSize)
                })
            }
        }) { (image, error, imageURL) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (imageURL == self.kf_webURL && image != nil) {
                    self.image = image;
                }
                completionHandler?(image: image, error: error, imageURL: imageURL)
            })
        }
        
        return task
    }
}

// MARK: - Associated Object
private var lastURLkey: Void?
public extension UIImageView {
    /// Get the image URL binded to this image view. You can use `kf_setImage` methods to set it.
    public var kf_webURL: NSURL? {
        get {
            return objc_getAssociatedObject(self, &lastURLkey) as? NSURL
        }
    }
    
    private func kf_setWebURL(URL: NSURL) {
        objc_setAssociatedObject(self, &lastURLkey, URL, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
}