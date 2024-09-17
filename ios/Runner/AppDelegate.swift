import Flutter
import UIKit
import GoogleMaps
import OtplessSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps SDK with your API key
    GMSServices.provideAPIKey("AIzaSyA2Nqezz1idcqRvJRXEu68O7t2aJC99Tyw")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // OtplessSDK integration for handling deep links
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if Otpless.sharedInstance.isOtplessDeeplink(url: url) {
      Otpless.sharedInstance.processOtplessDeeplink(url: url)
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
