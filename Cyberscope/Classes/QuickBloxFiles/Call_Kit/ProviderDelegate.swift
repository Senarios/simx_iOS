/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CallKit
import AVFoundation

class ProviderDelegate: NSObject, CXProviderDelegate, QBRTCClientDelegate
{
  fileprivate let callManager: CallManager
  fileprivate let provider: CXProvider
  fileprivate var action_timer: Timer?
    
  static var accepted = false

  fileprivate var CallKit_actionTimer: Timer?
    
    
  init(callManager: CallManager)
  {
    self.callManager = callManager
    provider = CXProvider(configuration: type(of: self).providerConfiguration)
    
    super.init()
    
    provider.setDelegate(self, queue: nil)
  }
    
    deinit {
        self.action_timer?.invalidate()
        self.action_timer = nil
        
        self.CallKit_actionTimer?.invalidate()
        self.CallKit_actionTimer = nil
    }
    
  static var providerConfiguration: CXProviderConfiguration
  {
    let providerConfiguration = CXProviderConfiguration(localizedName: Constants.strings.CyberScopeTV)
    
    providerConfiguration.supportsVideo = true
    providerConfiguration.maximumCallsPerCallGroup = 1
    providerConfiguration.supportedHandleTypes = [.phoneNumber]
    
    if let iconMaskImage = UIImage(named: "IconMask") {
        providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation(iconMaskImage)
    }
    providerConfiguration.ringtoneSound = "Ringtone.caf"
    
    return providerConfiguration
  }
  
  func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?)
  {
    QBRTCClient.instance().add(self)
    
    let update = CXCallUpdate()
    print("handle: String", handle, uuid)
    print(handle)
    let llhandle = handle == "NIL" ? "Scottish Health" : handle
    update.remoteHandle = CXHandle(type: .generic, value: llhandle)
    update.hasVideo = hasVideo
    
    //Display Name of the caler here in update
    
    provider.reportNewIncomingCall(with: uuid, update: update) { error in
      
        if error == nil {
        let call = Call(uuid: uuid, handle: handle)
        self.callManager.add(call: call)
      }
      
        completion?(error as NSError?)
    }
  }
   
    class func CloseCallKIT()
    {
        let callController = CXCallController()
        let UserUUID = UserDefaults.standard.value(forKey: Constants.Calling_Keys.uuid_str_for_call)
        if UserUUID != nil
        {
            let uuidStr = "\(UserUUID!)"
            let beaconUUID = NSUUID(uuidString: uuidStr)
            let end_call_action = CXEndCallAction(call: beaconUUID! as UUID)

            let trans = CXTransaction()
            trans.addAction(end_call_action)
            callController.request(trans, completion: { (err) in

                if(err == nil)
                {
                    print("CloseCallKIT action performed successfully!!")
                }
                else
                {
                    print("ERROR occured in CloseCallKIT method ... And error = \(String(describing: err?.localizedDescription)) ")
                }

                end_call_action.fulfill()
            })
        }
    }
    
    class func Accept_Call_on_CallKIT()
    {
        let callController = CXCallController()
        let UserUUID = UserDefaults.standard.value(forKey: Constants.Calling_Keys.uuid_str_for_call)
        if UserUUID != nil
        {
            let uuidStr = "\(UserUUID!)"
            let beaconUUID = NSUUID(uuidString: uuidStr)
            let accept_call_action = CXAnswerCallAction(call: beaconUUID! as UUID)
            
            let trans = CXTransaction()
            trans.addAction(accept_call_action)
            callController.request(trans, completion: { (err) in
                
                if(err == nil)
                {
                    print("Accept_Call_on_CallKIT action performed successfully!!")
                }
                else
                {
                    print("ERROR occured in Accept_Call_on_CallKIT method ... And error = \(String(describing: err?.localizedDescription)) ")
                }
                
                accept_call_action.fulfill()
            })
        }
    }
    var popupWindow: UIWindow?
    @objc private func accept_call()
    {
        if(AppDelegate.QB_VideoChat_session != nil)
        {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.action_timer?.invalidate()
                self.action_timer = nil

                
                let vc =  UIStoryboard(name: Constants.StoryBoards.StreamBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllers.CallingVC) as! CallingVC
                vc.acceptCall = true
//                vc.presentMeOnAlertWindow()
                vc.modalPresentationCapturesStatusBarAppearance = true
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                print ("I am ProviderDelegate 888, Window Presentation")
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.windowLevel = UIWindowLevelAlert + 1
                alertWindow.rootViewController = UIViewController() // as? UIViewController //UIViewController()
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(vc, animated: true, completion:nil)
                AppDelegate.shared_instance.popupWindow = alertWindow
            })
        }
    }

    @objc private func reject_call()
    {
        if(AppDelegate.QB_VideoChat_session != nil)
        {
            self.action_timer?.invalidate()
            self.action_timer = nil
            
            AppDelegate.QB_VideoChat_session?.rejectCall(nil)
        }
    }
    
    // *********************        DELEGATE METHODS        ************************** \\
    
    // CXProviderDelegate methods

    // MARK: - CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        stopAudio()
        
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction)
    {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        ProviderDelegate.accepted = true
        configureAudioSession()
        call.answer()
        
        self.action_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.accept_call), userInfo: nil, repeats: true)
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction)
    {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        stopAudio()
        
        call.end()
        
        self.action_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.reject_call), userInfo: nil, repeats: true)
        
        action.fulfill()
        
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        
        if call.state == .held {
            stopAudio()
        } else {
            startAudio()
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.callUUID, outgoing: true, handle: action.handle.value)
        configureAudioSession()
        
        call.connectedStateChanged = { [weak self] in
            guard let strongSelf = self else { return }
            
            if case .pending = call.connectedState {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if case .complete = call.connectedState {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                action.fulfill()
                strongSelf.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        startAudio()
    }
    
    // QBRTCClientDelegate methods
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil)
    {
        print("\n ** ProviderDelegate ** didReceiveNewSession called ... \n")
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber)
    {
        print("\n ** ProviderDelegate ** connectedToUser called with userID = \(userID) \n")
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        print("\n ** ProviderDelegate ** hungUpByUser called and userID = \(userID) \n")
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        print("\n ** ProviderDelegate ** rejectedByUser called and userID = \(userID) \n")
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber)
    {
        print("\n ** ProviderDelegate ** receivedRemoteVideoTrack called fromUser userID \(userID) \n")
    }
    
    func sessionDidClose(_ session: QBRTCSession)
    {
        print("\n ** ProviderDelegate ** sessionDidClose called ...\n")
        
        ProviderDelegate.CloseCallKIT()
        providerDidReset(self.provider)
        
        QBRTCClient.instance().remove(self)
        self.action_timer?.invalidate()
        self.action_timer = nil
    }
}

