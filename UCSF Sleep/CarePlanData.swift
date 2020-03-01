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

enum ActivityIdentifier: String {
  case sleepDuration
  case sleepTime
  case sleepQuality
  case checkedPhone
}

class CarePlanData: NSObject {
  let carePlanStore: OCKCarePlanStore

  class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
    return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek,
                                         occurrencesPerDay: occurencesPerDay)
  }

  init(carePlanStore: OCKCarePlanStore) {
    self.carePlanStore = carePlanStore
        
    let durationActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.duration.rawValue,
                  groupIdentifier: nil,
                  title: "Sleep Duration",
                  text: "How long did you Sleep?",
                  tintColor: UIColor.lightBlue(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makeDurationAssessmentTask()])
    
    let timeActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.starttime.rawValue,
                  groupIdentifier: nil,
                  title: "Sleep Time",
                  text: "What time did you fall asleep?",
                  tintColor: UIColor.lightBlue(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makeTimeAssessmentTask()])

    let qualityActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.quality.rawValue,
                  groupIdentifier: nil,
                  title: "Sleep Quality",
                  text: "Do you feel well rested after sleeping?",
                  tintColor: UIColor.lightBlue(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makeQualityAssessmentTask()])

    let checkActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.checking.rawValue,
                  groupIdentifier: nil,
                  title: "Checked Phone",
                  text: "Did you check your phone during the night/while trying to fall asleep?",
                  tintColor: UIColor.lightBlue(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makeCheckedAssessmentTask()])

    
    super.init()
    
    for activity in [durationActivity, timeActivity, qualityActivity, checkActivity] {
                      add(activity: activity)
    }
  }
  
  func add(activity: OCKCarePlanActivity) {
    carePlanStore.activity(forIdentifier: activity.identifier) {
      [weak self] (success, fetchedActivity, error) in
      guard success else { return }
      guard let strongSelf = self else { return }

      if let _ = fetchedActivity { return }
      
      strongSelf.carePlanStore.add(activity, completion: { _ in })
    }
  }
}

extension CarePlanData {
  func generateDocumentWith(chart: OCKChart?) -> OCKDocument {
    let intro = OCKDocumentElementParagraph(content: "I've been tracking my efforts to improve my quality of sleep! Check out my report to see how I'm doing.")
    
    var documentElements: [OCKDocumentElement] = [intro]
    if let chart = chart {
      documentElements.append(OCKDocumentElementChart(chart: chart))
    }
    
    let document = OCKDocument(title: "Re: Sleep Report", elements: documentElements)
    document.pageHeader = "UCSFSleep: Weekly Report"
    
    return document
  }
}