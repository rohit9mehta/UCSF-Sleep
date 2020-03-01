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

import ResearchKit

struct AssessmentTaskFactory {
  static func makeDurationAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.duration)!
    let unit = HKUnit(from: "hours")
    let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
    
    // Create a question.
    let title = "How long did you sleep this night?"
    let text = "Please enter the lenght of sleep in hours below."
    let questionStep = ORKQuestionStep(identifier: "DurationStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "DurationTask", steps: [questionStep])
  }
  
  static func makeTimeAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.starttime)!
    let answerFormat = let answerFormat = ORKTimeOfDayAnswerFormat()
    
    // Create a question.
    let title = "What time did you go to sleep last night?"
    let text = "Please enter the time you went to bed last night below in a 24hours format."
    let questionStep = ORKQuestionStep(identifier: "TimeStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "TimeTask", steps: [questionStep])
  }

  static func makeQualityAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.quality)!
    let answerFormat = let answerFormat = ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 5, step: 1, vertical: false)
    
    // Create a question.
    let title = "How was your quality of sleep last night?"
    let text = "Please choose your perceived quality of sleep below on a scale of 0 to 10."
    let questionStep = ORKQuestionStep(identifier: "QualityStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "QualityTask", steps: [questionStep])
  }

  static func makeCheckedAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.checked)!
    let answerFormat = let answerFormat = ORKBooleanAnswerFormat()
    
    // Create a question.
    let title = "Did you check your phone?"
    let text = "Please tell us whether you checked your phone during the night or while trying to fall asleep."
    let questionStep = ORKQuestionStep(identifier: "CheckedStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "CheckedTask", steps: [questionStep])
  }
}
