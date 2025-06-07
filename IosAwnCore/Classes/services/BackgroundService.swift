//
//  BackgroundService.swift
//  awesome_notifications
//
//  Created by CardaDev on 02/02/22.
//

import Foundation

class BackgroundService {
    
    static let TAG = "BackgroundService"
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:BackgroundService?
    public static var shared:BackgroundService {
        get {
            BackgroundService.instance =
                BackgroundService.instance ?? BackgroundService()
            return BackgroundService.instance!
        }
    }
    private init(){}
    
    // ********************************************************
    
    public func enqueue(
        SilentBackgroundAction silentAction: ActionReceived,
        withCompletionHandler completionHandler: @escaping (Bool, Error?) -> ()
    ){
        Logger.shared.d("ELFIE","ELFIE DEBUG => BackgroundService.enqueue()")
        let start = DispatchTime.now()
        Logger.shared.d(BackgroundService.TAG, "A new Dart background service has started")
        
        let completionWithTimer:(Bool, Error?) -> () = { (success, error) in
            Logger.shared.d("ELFIE","ELFIE DEBUG => BackgroundService completion with timer: success=\(success)")
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval:Double = Double(nanoTime) / 1_000_000
            Logger.shared.d(BackgroundService.TAG, "Background action finished in \(timeInterval.rounded())ms")
            
            completionHandler(success, error)
        }
        
        do {
            let backgroundCallback:Int64 = DefaultsManager.shared.backgroundCallback
            let actionCallback:Int64 = DefaultsManager.shared.actionCallback
            
            Logger.shared.d("ELFIE","ELFIE DEBUG => BackgroundService callbacks: background=\(backgroundCallback), action=\(actionCallback)")
            
            if backgroundCallback == 0 {
                Logger.shared.d("ELFIE","ELFIE DEBUG => No valid background handler registered")
                throw ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: BackgroundService.TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "A background message could not be handled in Dart because there is no valid background handler register",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".enqueue.backgroundCallback")
            }
            
            if actionCallback == 0 {
                Logger.shared.d("ELFIE","ELFIE DEBUG => No valid action callback handler registered")
                throw ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: BackgroundService.TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "A background message could not be handled in Dart because there is no valid action callback handler register",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".enqueue.backgroundCallback")
            }
            
            if Thread.isMainThread {
                Logger.shared.d("ELFIE","ELFIE DEBUG => Running on main thread")
                mainThreadServiceExecution(
                    SilentBackgroundAction: silentAction,
                    backgroundCallback: backgroundCallback,
                    actionCallback: actionCallback,
                    withCompletionHandler: completionWithTimer)
            }
            else {
                Logger.shared.d("ELFIE","ELFIE DEBUG => Running on background thread")
                try backgroundThreadServiceExecution(
                    SilentBackgroundAction: silentAction,
                    backgroundCallback: backgroundCallback,
                    actionCallback: actionCallback,
                    withCompletionHandler: completionWithTimer)
            }
            
        } catch {
            Logger.shared.d("ELFIE","ELFIE DEBUG => Error in BackgroundService.enqueue: \(error.localizedDescription)")
            if error is AwesomeNotificationsException {
                completionWithTimer(false, error)
            } else {
                completionWithTimer(
                    false,
                    ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: BackgroundService.TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "A background message could not be handled in Dart because there is no valid background handler register",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".enqueue.backgroundCallback"))
            }
        }
    }
    
    func mainThreadServiceExecution(
        SilentBackgroundAction silentAction: ActionReceived,
        backgroundCallback:Int64,
        actionCallback:Int64,
        withCompletionHandler completionHandler: @escaping (Bool, Error?) -> ()
    ){
        Logger.shared.d("ELFIE","ELFIE DEBUG => mainThreadServiceExecution()")
        let silentActionRequest:SilentActionRequest =
                SilentActionRequest(
                    actionReceived: silentAction,
                    handler: { success in
                        Logger.shared.d("ELFIE","ELFIE DEBUG => SilentActionRequest handler: success=\(success)")
                        completionHandler(success, nil)
                    })
        
        let backgroundExecutor:BackgroundExecutor =
                AwesomeNotifications
                    .backgroundClassType!
                    .init()
        
        Logger.shared.d("ELFIE","ELFIE DEBUG => Running background process through BackgroundExecutor")
        backgroundExecutor
            .runBackgroundProcess(
                silentActionRequest: silentActionRequest,
                dartCallbackHandle: backgroundCallback,
                silentCallbackHandle: actionCallback)
    }
    
    func backgroundThreadServiceExecution(
        SilentBackgroundAction silentAction: ActionReceived,
        backgroundCallback:Int64,
        actionCallback:Int64,
        withCompletionHandler completionHandler: @escaping (Bool, Error?) -> ()
    ) throws {
        Logger.shared.d("ELFIE","ELFIE DEBUG => backgroundThreadServiceExecution()")
        let group = DispatchGroup()
        group.enter()
        
        let silentActionRequest:SilentActionRequest =
                SilentActionRequest(
                    actionReceived: silentAction,
                    handler: { success in
                        Logger.shared.d("ELFIE","ELFIE DEBUG => SilentActionRequest handler: success=\(success)")
                        group.leave()
                    })
        
        let workItem:DispatchWorkItem = DispatchWorkItem {
            Logger.shared.d("ELFIE","ELFIE DEBUG => WorkItem executing")
            DispatchQueue.global(qos: .background).async {
                Logger.shared.d("ELFIE","ELFIE DEBUG => Inside global background queue")
                
                let backgroundExecutor:BackgroundExecutor =
                        AwesomeNotifications
                            .backgroundClassType!
                            .init()
                
                Logger.shared.d("ELFIE","ELFIE DEBUG => Running background process through BackgroundExecutor")
                backgroundExecutor
                    .runBackgroundProcess(
                        silentActionRequest: silentActionRequest,
                        dartCallbackHandle: backgroundCallback,
                        silentCallbackHandle: actionCallback)
            }
            
        }
        
        workItem.perform()
        if group.wait(timeout: DispatchTime.now() + .seconds(10)) == .timedOut {
            Logger.shared.d("ELFIE","ELFIE DEBUG => Background service timeout reached")
            workItem.cancel()
            throw ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: BackgroundService.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Background silent push service reached timeout limit",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".mainThreadServiceExecution.timeout")
        }
    }
    
}
