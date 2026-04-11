import UIKit

class SimpleTabBarController: UITabBarController {
    private var kvoToken: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVC = UIViewController()
        firstVC.view.backgroundColor = .systemBlue
        firstVC.tabBarItem = UITabBarItem(title: "First", image: nil, tag: 0)
        
        let secondVC = UIViewController()
        secondVC.view.backgroundColor = .systemGreen
        secondVC.tabBarItem = UITabBarItem(title: "Second", image: nil, tag: 1)
        
        viewControllers = [firstVC, secondVC]
        
        // KVO observer for selectedIndex
        kvoToken = observe(\SimpleTabBarController.selectedIndex, options: [.new]) { [weak self] _, change in
            if let newIndex = change.newValue {
                print("Tab changed to index: \(newIndex)")
            }
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
}
