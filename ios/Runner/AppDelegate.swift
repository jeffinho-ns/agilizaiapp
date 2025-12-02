import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configuração do Google Maps
    GMSServices.provideAPIKey("AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k")
    
    // Registra plugins do Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    // Configurações adicionais para evitar problemas de memória
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
