import FIXiT
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

@objc(FIXiTPackageTestSubject)
final class FIXiTPackageTestSubject: NSObject {
    @objc dynamic func value() -> String {
        return "original"
    }
}

enum FIXiTPackageIntegration {
    static func bootstrap() -> (String?, Int32?) {
        let fixit = FIXiT.fix()
        let context = FIXiT.context()
        fixit.executeScript("global.__fixitPackageTest = 6 * 7;")
        return (
            context.evaluateScript("typeof makeProxiedObject")?.toString(),
            context.objectForKeyedSubscript("__fixitPackageTest")?.toInt32()
        )
    }

    static func patchMethod() -> (String, String) {
        let subject = FIXiTPackageTestSubject()
        let original = subject.value()
        FIXiT.fix().executeScript("""
            Fixit.fix('FIXiTPackageTestSubject').instanceMethod('value', function () {
                return 'patched';
            });
            """)
        return (original, subject.value())
    }
}
