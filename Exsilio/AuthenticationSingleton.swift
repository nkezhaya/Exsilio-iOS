//
//  AuthenticationSingleton.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 12/10/16.
//
//

import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class AuthenticationSingleton {
    fileprivate init() {}
    static let shared = AuthenticationSingleton()

    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Settings.accessTokenKey)
        }

        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: Settings.accessTokenKey)
            } else {
                UserDefaults.standard.set(newValue, forKey: Settings.accessTokenKey)
            }
        }
    }

    var currentUser: JSON?

    func isLoggedIn() -> Bool {
        return accessToken != nil || FBSDKAccessToken.current() != nil
    }

    func login(email: String, password: String, success: (() -> Void)? = nil, failure: ((GenericError) -> Void)? = nil) {
        Alamofire.request(AuthenticationRouter.login(email, password)).responseJSON(completionHandler: authResponseHandler(success, failure: failure))
    }

    func loggedInWithFacebook() {
        refreshCurrentUser {
            NotificationCenter.default.post(name: .userLoggedIn, object: nil)
        }
    }

    func register(with params: Parameters, success: (() -> Void)? = nil, failure: ((GenericError) -> Void)? = nil) {
        Alamofire.request(AuthenticationRouter.register(params)).responseJSON(completionHandler: authResponseHandler(success, failure: failure))
    }

    func forgotPassword(email: String, success: (() -> Void)? = nil) {
        Alamofire.request(AuthenticationRouter.forgotPassword(email)).validate().responseJSON { response in
            switch response.result {
            case .success:
                success?()
            case .failure(let error):
                ErrorHelper.handle(serverError: error, response: response)
            }
        }
    }

    func changePassword(params: Parameters, success: (() -> Void)? = nil) {
        Alamofire.request(AuthenticationRouter.changePassword(params)).validate().responseJSON { response in
            switch response.result {
            case .success:
                success?()
            case .failure(let error):
                ErrorHelper.handle(serverError: error, response: response)
            }
        }
    }

    func refreshCurrentUser(_ completion: (() -> Void)? = nil) {
        Alamofire.request(AuthenticationRouter.me).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if json["user"] != nil {
                    var shouldNotify = false

                    if self.currentUser == nil {
                        shouldNotify = true
                    }

                    self.currentUser = json["user"]

                    if shouldNotify {
                        NotificationCenter.default.post(name: .userLoggedIn, object: nil)
                    }
                } else {
                    self.logOut()
                }

                completion?()
            case .failure(_):
                break
            }
        }
    }

    func logOut() {
        FBSDKLoginManager().logOut()
        accessToken = nil
        currentUser = nil
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }

    fileprivate func authResponseHandler(_ success: (() -> Void)? = nil, failure: ((GenericError) -> Void)? = nil) -> ((DataResponse<Any>) -> Void) {
        return { response in
            switch response.result {
            case .success(let data):
                self.loginSuccessHandler(JSON(data), success: success, failure: failure)
            case .failure(let error):
                failure?(GenericError.error(error.localizedDescription))
            }
        }
    }

    fileprivate func loginSuccessHandler(_ json: JSON, success: (() -> Void)? = nil, failure: ((GenericError) -> Void)? = nil) {
        if json["user"] != nil {
            currentUser = json["user"]
            accessToken = json["user"]["authentication_token"].string

            NotificationCenter.default.post(name: .userLoggedIn, object: nil)

            success?()
        } else {
            let reason: String

            if let error = json["error"].string {
                reason = error
            } else {
                reason = "Login failed for an unknown reason."
            }

            failure?(GenericError.error(reason))
        }
    }

    fileprivate func userResponseHandler(_ success: (() -> Void)? = nil, failure: ((GenericError) -> Void)? = nil) -> ((DataResponse<Any>) -> Void) {
        return { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if json["user"] != nil {
                    self.currentUser = json["user"]
                    success?()
                } else {
                    self.logOut()
                }
            case .failure(let error):
                self.logOut()
                failure?(GenericError.error(error.localizedDescription))
            }
        }
    }

    enum AuthenticationRouter: URLRequestConvertible {
        case login(String, String)
        case register(Parameters)
        case forgotPassword(String)
        case changePassword(Parameters)
        case me

        var path: String {
            switch self {
            case .login:
                return "/users/sign_in.json"
            case .register:
                return "/users.json"
            case .forgotPassword:
                return "/passwords.json"
            case .changePassword:
                return "/passwords.json"
            case .me:
                return "/users/me.json"
            }
        }

        var parameters: Parameters? {
            switch self {
            case .login(let email, let password):
                return ["user": ["email": email, "password": password]]
            case .register(let registrationParams):
                return ["user": registrationParams]
            case .forgotPassword(let email):
                return ["email": email]
            case .changePassword(let params):
                return ["user": params]
            default:
                return nil
            }
        }

        var method: Alamofire.HTTPMethod {
            switch self {
            case .me:
                return .get
            case .changePassword:
                return .patch
            default:
                return .post
            }
        }

        func asURLRequest() throws -> URLRequest {
            let url = URL(string: API.URL)
            var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            let encoding = Alamofire.URLEncoding.default

            switch self {
            case .me: fallthrough
            case .changePassword:
                urlRequest.addAuthHeader()
            default:
                break
            }
            
            return try encoding.encode(urlRequest, with: parameters)
        }
    }
}
