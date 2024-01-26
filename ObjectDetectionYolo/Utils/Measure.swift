//
//  Measure.swift
//  ObjectDetectionYolo
//
//  Created by Raghvender on 24/01/24.
//

import UIKit

protocol MeasureDelegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int)
}

class Measure {
    var delegate: MeasureDelegate?
    var index: Int = -1
    var measurements: [Dictionary<String, Double>]
    
    init() {
        let measurement = [
            "start": CACurrentMediaTime(),
            "end": CACurrentMediaTime()
        ]
        measurements = Array<Dictionary<String, Double>>(repeating: measurement, count: 30)
    }
    
    func start() {
        index += 1
        index %= 30
        measurements[index] = [:]
        
        label(for: index, with: "start")
    }
    
    func stop() {
        label(for: index, with: "end")
        
        let beforeMeasurement = getBeforeMeasurement(for: index)
        let currentMeasurement = measurements[index]
        if let startTime = currentMeasurement["start"],
           let endInferenceTime = currentMeasurement["end"],
           let endTime = currentMeasurement["end"],
           let beforeStartTime = beforeMeasurement["start"] {
            delegate?.updateMeasure(inferenceTime: endInferenceTime - startTime, executionTime: endTime - startTime, fps: Int(1 / (startTime - beforeStartTime)))
        }
    }
    
    func label(with msg: String? = "") {
        label(for: index, with: msg)
    }
    
    private func label(for index: Int, with msg: String? = "") {
        if let message = msg {
            measurements[index][message] = CACurrentMediaTime()
        }
    }
    
    private func getBeforeMeasurement(for index: Int) -> Dictionary<String, Double> {
        return measurements[(index + 30 - 1) % 30]
    }
    
    func log() {
        
    }
}


class MeasureLogView: UIView {
    let estimateLabel = UILabel(frame: .zero)
    let fpsLabel = UILabel(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
