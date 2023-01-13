//
//  AWSManager.swift
//  WhosNext
//
//  Created by differenz240 on 18/11/22.
//

import UIKit
import AVKit
import AWSCore
import AWSS3

enum AWSMediaContentType: String {
    case imageJpeg = "image/jpeg"
    case video = "video"
    case audio = "audio"
}

enum AWSBucket: String {
    case mainBucket  = "whosnextmobileapp"
    
    /// `common` folders
    case introVideo = "introduction_video/video"
    case introThumbnail = "introduction_video/thumb"
    
    /// `post` module folders
    case postImage = "post_image/image"
    case postVideo = "post_video/video"
    case postVideoThumb = "post_video/thumb"
    
    /// `snippet` module folders
    case snippetImage = "snippet/image"
    case snippetVideo = "snippet/video"
    case snippetAudio = "snippet/audio"
    case snippetThumb = "snippet/thumb"
    
    /// `bcl` module folders
    case bclImage = "bcl/image"
}

class AWSS3Manager: NSObject {
    /// `AWS S3 Bucket Keys`
    let accessKey = AWS.accesskey
    let secretKey =  AWS.secretkey
    
    static let shared = AWSS3Manager()
    
    override init() {
        super.init()
        
        /// `AWS Bucket Configurations`
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: self.accessKey, secretKey: self.secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    /// `upload image to aws s3`
    func uploadImage(image: UIImage, bucketname: AWSBucket, withSuccess success: @escaping (_ success: String, _ thumbName: String) -> Void, failure: @escaping (_ error: String) -> Void, connectionFail: @escaping (_ error: String) -> Void)  {
        let timeInSeconds = String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "_")
        let tmpPath = NSTemporaryDirectory() as String
        print(timeInSeconds)
        
        var remoteName = "\(timeInSeconds)_image.jpg"
        
        let fileURL = URL(fileURLWithPath: tmpPath).appendingPathComponent(remoteName)
        let orientationImage = image.imageOrientation()
        
        do {
            let data = orientationImage.jpegData(compressionQuality: JPEGQuality.low.rawValue)
            let imageSize = (data?.count ?? 0 ) / 1024 // kb Size
            print("Upload Image Size: \(imageSize) kb")
            try data?.write(to: fileURL)
        } catch {
            print("Fail")
        }
        
        remoteName = "\(bucketname.rawValue)/\(timeInSeconds)_image.jpg"
        
        self.uploadMedia(fileURL: fileURL, fileName: remoteName, bucketname: bucketname, contentType: .imageJpeg, withSuccess: { fileURL -> Void in
            success(fileURL, remoteName)
        }, failure: { error -> Void in
            failure(error)
            
            Indicator.hide()
        }, connectionFail: { error -> Void in
            connectionFail(error)
            
            Indicator.hide()
        })
    }
    
    /// `upload video to aws s3`
    func uploadVideo(video: URL, bucketname: AWSBucket, withSuccess success: @escaping (_ success: String,_ thumbName: String) -> Void, failure: @escaping (_ error: String) -> Void, connectionFail: @escaping (_ error: String) -> Void)  {
        let timeInSeconds = String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "_")
        print(timeInSeconds)
        
        var remoteName = "\(timeInSeconds)_video.mp4"
        
        do {
            let data = try Data(contentsOf: video)
            let videoSize = (data.count) / 1024 // kb Size
            print("Upload Video Size: \(videoSize) kb")
        } catch {
            print("Fail")
        }
        
        remoteName = "\(bucketname.rawValue)/\(timeInSeconds)_video.mp4"
        
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        self.compressVideo(inputURL: video as URL, outputURL: compressedURL) { exportSession in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard let compressedData = try? Data(contentsOf: compressedURL) else {
                        return
                    }
                    
                    print("File size after compression: \(Double(compressedData.count / 1024)) kb")
                    self.uploadMedia(fileURL: compressedURL, fileName: remoteName, bucketname: bucketname, contentType: .video, withSuccess: { fileURL -> Void in
                        success(fileURL, remoteName)
                    }, failure: { error -> Void in
                        failure(error)
                        
                        Indicator.hide()
                    }, connectionFail: { error -> Void in
                        connectionFail(error)
                        
                        Indicator.hide()
                    })
                case .failed:
                    break
                case .cancelled:
                    break
                @unknown default:
                    break
            }
        }
    }
    
    /// `upload audio to aws s3`
    func uploadAudio(audio: URL, bucketname: AWSBucket, withSuccess success: @escaping (_ success:String,_ thumbName: String) -> Void, failure: @escaping (_ error: String) -> Void, connectionFail: @escaping (_ error: String) -> Void)  {
        let timeInSeconds = String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "_")
        print(timeInSeconds)
        
        var remoteName = "\(timeInSeconds)_audio.m4a"
        
        do {
            let data = try Data(contentsOf: audio)
            let audioSize = (data.count) / 1024 // kb Size
            print("Upload Audio Size: \(audioSize) kb")
        } catch {
            print("Fail")
        }
        
        remoteName = "\(bucketname.rawValue)/\(timeInSeconds)_audio.m4a"
        
        self.uploadMedia(fileURL: audio, fileName: remoteName, bucketname: bucketname, contentType: .audio, withSuccess: { fileURL -> Void in
            success(fileURL, remoteName)
        }, failure: { error -> Void in
            failure(error)
            
            Indicator.hide()
        }, connectionFail: { error -> Void in
            connectionFail(error)
            
            Indicator.hide()
        })
    }

    /// `upload image to aws s3`
    private func uploadMedia(fileURL: URL, fileName: String, bucketname: AWSBucket, contentType: AWSMediaContentType, withSuccess success: @escaping (_ success:String) -> Void, failure: @escaping (_ error: String) -> Void, connectionFail: @escaping (_ error: String) -> Void) {
        
        let transferUtitity = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityUploadExpression()
        
        let completionHandler : AWSS3TransferUtilityUploadCompletionHandlerBlock = { task, error -> Void in
            if let error = error {
                print("Failed with error: \(error)")
                failure(error.localizedDescription)
            } else {
                if let response = task.response?.description {
                    print(response.description)
                }

                if task.status == .completed {
                    let updatedURL = URL(string: "https://\(AWSBucket.mainBucket.rawValue).s3.us-west-2.amazonaws.com/")
                    let publicURL = updatedURL?.appendingPathComponent(fileName)

                    if let absoluteString = publicURL?.absoluteString {
                        print("Uploaded to: \(absoluteString)")

                        success(absoluteString)
                    }
                } else {
                    print("task status: \(task.status.rawValue)")
                }
            }
        }
        
        transferUtitity.uploadFile(fileURL, bucket: AWSBucket.mainBucket.rawValue, key: fileName, contentType: contentType.rawValue, expression: expression, completionHandler: completionHandler)
            .continueWith { task -> AnyObject? in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                    print("Upload failed with error: (\(error.localizedDescription))")
                    let errorMsg = "Upload failed with error: (\(error.localizedDescription))"
                    print(errorMsg)
                }
                
                if let result = task.result {
                    print(result)
                    print(result.status.rawValue)
                }
                
                return nil
            }
    }
    
    /// `delete media from aws s3`
    func deleteMedia(fileName: String, bucket: AWSBucket, withSuccess success: @escaping (_ success: String) -> Void, failure: @escaping (_ error: String) -> Void) {
        let s3Service = AWSS3.default()
        
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = bucket.rawValue
        deleteObjectRequest?.key = fileName
        
        s3Service.deleteObject(deleteObjectRequest!).continueWith { (task: AWSTask) -> AnyObject? in
            if let error = task.error {
                failure(error.localizedDescription)
            }
            
            success("Bucket deleted successfully.")
            
            return nil
        }
    }
    
    
    /// `get signed url for aws s3`
    func getSignedUrl(key: String, withSuccess success: @escaping (String) -> Void) -> Void {
//        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
//        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
//        getPreSignedURLRequest.key = key
//        getPreSignedURLRequest.bucket = AWSBucket.mainBucket.rawValue
//        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)
//
//        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task: AWSTask<NSURL>) -> Any? in
//            if let error = task.error as NSError? {
//                print("error generating signed url: \(error)")
//                return nil
//            }
//
//            let preSignedURLString = task.result?.absoluteString ?? ""

//            print(key)

            success("https://d234fq55kjo26g.cloudfront.net/\(key)")

            
//        }
    }
}

// MARK: - Functions
extension AWSS3Manager {
    /// `get media url from file name`
    func getMediaUrl(name: String, bucketName: AWSBucket) -> String {
        return "\(bucketName.rawValue)/\(name)"
    }
    
    /// `compress video to aws s3`
    private func compressVideo(inputURL: URL, outputURL: URL, handler: @escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
}
