//
//  CMTime+Extension.swift
//  iMusic
//
//  Created by Maxim Alekseev on 17.12.2020.
//

import Foundation
import AVKit

extension CMTime {
    func toDisplayString() -> String {
        
        guard !CMTimeGetSeconds(self).isNaN else { return "" }
        
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
