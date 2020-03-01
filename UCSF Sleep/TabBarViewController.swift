import UIKit
import CareKit

fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
fileprivate var symptomTrackerViewController: OCKSymptomTrackerViewController? = nil
fileprivate let carePlanData: CarePlanData
fileprivate var insightsViewController: OCKInsightsViewController? = nil
fileprivate var insightChart: OCKBarChart? = nil

class TabBarViewController: UITabBarController {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    carePlanStoreManager.delegate = self
    carePlanStoreManager.updateInsights()

    let symptomTrackerStack = createSymptomTrackerStack()
    let insightsStack = createInsightsStack()
    
    self.viewControllers = [symptomTrackerStack,
                            insightsStack]
    
    tabBar.tintColor = UIColor.darkOrange()
    tabBar.barTintColor = UIColor.lightGreen()
  }

  
  fileprivate func createSymptomTrackerStack() -> UINavigationController {
    let viewController = OCKSymptomTrackerViewController(carePlanStore: carePlanStoreManager.store)
    viewController.progressRingTintColor = UIColor.lightBlue()
    symptomTrackerViewController = viewController
    
    viewController.tabBarItem = UITabBarItem(title: "Check In", image: UIImage(named: "symptoms"), selectedImage: UIImage.init(named: "symptoms-filled"))
    viewController.title = "Check In"
    
    return UINavigationController(rootViewController: viewController)
  }
  
  fileprivate func createInsightsStack() -> UINavigationController {
    let viewController = OCKInsightsViewController(insightItems: [OCKInsightItem.emptyInsightsMessage()], headerTitle: "Progress Report", headerSubtitle: "Your overall quality of sleep")
    insightsViewController = viewController
    
    viewController.tabBarItem = UITabBarItem(title: "Report", image: UIImage(named: "insights"), selectedImage: UIImage.init(named: "insights-filled"))
    viewController.title = "Personal Report"
    return UINavigationController(rootViewController: viewController)
  }
  
}

extension TabBarViewController: OCKSymptomTrackerViewControllerDelegate {
  func symptomTrackerViewController(_ viewController: OCKSymptomTrackerViewController,
                                    didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
    guard let userInfo = assessmentEvent.activity.userInfo,
      let task: ORKTask = userInfo["ORKTask"] as? ORKTask else { return }
    
    let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
    viewController.delegate = self
    taskViewController.delegate = self
    
    present(taskViewController, animated: true, completion: nil)
  }
}

extension TabBarViewController: ORKTaskViewControllerDelegate {
  func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith
    reason: ORKTaskViewControllerFinishReason, error: Error?) {
    // 1
    defer {
      dismiss(animated: true, completion: nil)
    }
    
    // 2
    guard reason == .completed else { return }
    guard let symptomTrackerViewController = symptomTrackerViewController,
      let event = symptomTrackerViewController.lastSelectedAssessmentEvent else { return }
   
    let carePlanResult = carePlanStoreManager.buildCarePlanResultFrom(taskResult: taskViewController.result)
    carePlanStoreManager.store.update(event, with: carePlanResult, state: .completed) {
      success, _, error in
      if !success {
        print(error?.localizedDescription)
  }
}
  }
}

extension TabBarViewController: CarePlanStoreManagerDelegate {
  func carePlanStore(_ store: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem]) {
    insightsViewController?.items = insights
  }
}
