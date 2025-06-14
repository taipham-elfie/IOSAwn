//
//  MediaUtils.swift
//  awesome_notifications
//
//  Created by Rafael Setragni on 05/09/20.
//

import Foundation

open class MediaUtils {

    func matchMediaType(regex:String, mediaPath:String?) -> Bool {
        return matchMediaType(regex:regex, mediaPath:mediaPath, filterEmpty:true);
    }

    func matchMediaType(regex:String, mediaPath:String?, filterEmpty:Bool) -> Bool {
        return (mediaPath?.matches(regex) ?? false) && (!filterEmpty || !StringUtils.shared.isNullOrEmpty(mediaPath))
    }

    func getMediaSourceType(mediaPath:String?) -> MediaSource {

        if (mediaPath != nil) {

            if (matchMediaType(regex:Definitions.MEDIA_VALID_NETWORK, mediaPath:mediaPath, filterEmpty:false)) {
                return MediaSource.Network;
            }

            if (matchMediaType(regex:Definitions.MEDIA_VALID_FILE, mediaPath:mediaPath)) {
                return MediaSource.File;
            }

            if (matchMediaType(regex:Definitions.MEDIA_VALID_RESOURCE, mediaPath:mediaPath)) {
                return MediaSource.Resource;
            }
            
            if (matchMediaType(regex:Definitions.MEDIA_VALID_LIBRARY, mediaPath:mediaPath)) {
                return MediaSource.Library;
            }

            if (matchMediaType(regex:Definitions.MEDIA_VALID_ASSET, mediaPath:mediaPath)) {
                return MediaSource.Asset;
            }

        }
        return MediaSource.Unknown;
    }

    func cleanMediaPath(mediaPath:String?) -> String? {
        
        if (mediaPath != nil) {
            
            var cleanMedia = mediaPath ?? ""
            
            if(
                cleanMedia.replaceRegex(Definitions.MEDIA_VALID_NETWORK, replaceWith: "$2") ||
                cleanMedia.replaceRegex(Definitions.MEDIA_VALID_FILE, replaceWith: "") ||
                cleanMedia.replaceRegex(Definitions.MEDIA_VALID_ASSET, replaceWith: "") ||
                cleanMedia.replaceRegex(Definitions.MEDIA_VALID_RESOURCE, replaceWith: "") ||
                cleanMedia.replaceRegex(Definitions.MEDIA_VALID_LIBRARY, replaceWith: "")
            ){
                return cleanMedia;
            }
        }
        return nil;
    }
}
