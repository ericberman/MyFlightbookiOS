/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  FixedImageCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/1/23.
//

import Foundation

@objc public class FixedImageCell : UITableViewCell {
    public override func layoutSubviews() {
        super.layoutSubviews()
        let f = contentView.frame
        let MARGIN = 3.0
        
        // x, y, width, height
        let dxWidth = f.size.height * 1.2
        let dxHeight = f.size.height
        
        let dxAccessory = 0.0
        
        let rImage = CGRectMake(MARGIN, 1.0, dxWidth - 2 * MARGIN, dxHeight - 1.0)
        imageView!.frame = rImage
        imageView!.contentMode = .scaleAspectFit
        
        let xLabels = rImage.origin.x + rImage.size.width + MARGIN
        
        let rText = CGRectMake(xLabels, textLabel!.frame.origin.y, f.size.width - xLabels - dxAccessory - 2.0 * MARGIN, textLabel!.frame.size.height)
        textLabel!.frame = rText;
        
        let rDetail = CGRectMake(xLabels, detailTextLabel!.frame.origin.y, f.size.width - xLabels - dxAccessory - 2.0 * MARGIN, detailTextLabel!.frame.size.height)
        detailTextLabel!.frame = rDetail
    }
}
