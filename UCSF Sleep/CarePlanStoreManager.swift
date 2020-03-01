/**
 * Copyright (c) 2016 Razeware LLC
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

import CareKit
import ResearchKit

protocol CarePlanStoreManagerDelegate: class {
  func carePlanStore(_: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem])
}

class CarePlanStoreManager: NSObject {
  static let sharedCarePlanStoreManager = CarePlanStoreManager()
  var store: OCKCarePlanStore
  weak var delegate: CarePlanStoreManagerDelegate?

  override init() {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else {
      fatalError("Failed to obtain Documents directory!")
    }
    
    let storeURL = documentDirectory.appendingPathComponent("CarePlanStore")
    
    if !fileManager.fileExists(atPath: storeURL.path) {
      try! fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    store = OCKCarePlanStore(persistenceDirectoryURL: storeURL)
    super.init()
    store.delegate = self
  }
  
  func buildCarePlanResultFrom(taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
    guard let firstResult = taskResult.firstResult as? ORKStepResult,
      let stepResult = firstResult.results?.first else {
        fatalError("Unexepected task results")
    }
    
    if let numericResult = stepResult as? ORKNumericQuestionResult,
      let answer = numericResult.numericAnswer {
      return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit, userInfo: nil)
    }
    
    fatalError("Unexpected task result type")
  }
  
  func updateInsights() {
    InsightsDataManager().updateInsights { (success, insightItems) in
      guard let insightItems = insightItems, success else { return }
      self.delegate?.carePlanStore(self.store, didUpdateInsights: insightItems)
    }
  }
}

// MARK: - OCKCarePlanStoreDelegate
extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
  func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
    updateInsights()
  }
}
