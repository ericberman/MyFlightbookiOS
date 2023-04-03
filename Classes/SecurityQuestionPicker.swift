//
//  SecurityQuestionPicker.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/3/23.
//

import Foundation

@objc public class SecurityQuestionPicker : UITableViewController {
    @objc public var nuo : NewUserObject!
    
    private let rgQuestions = String(localized: "SecurityQuestions", comment: "Security Questions").components(separatedBy: "\n")
    
    // MARK: - Table View Data Source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rgQuestions.count
    }
    
    private let fontHeight = 16.0

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sz = rgQuestions[indexPath.row] as NSString
        let h = sz.boundingRect(with: CGSizeMake(tableView.frame.size.width - 20, 10000),
                                options: .usesLineFragmentOrigin,
                                attributes: [.font : UIFont.systemFont(ofSize: fontHeight)],
                                context: nil).size.height
        
        return ceil(h) + fontHeight
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tc = TextCell.getTextCellTransparent(tableView)
        tc.txt.text = rgQuestions[indexPath.row]
        tc.txt.numberOfLines = 20
        tc.txt.font = UIFont.systemFont(ofSize: fontHeight)
        tc.txt.adjustsFontSizeToFitWidth = false
        return tc
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nuo.szQuestion = rgQuestions[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
}
