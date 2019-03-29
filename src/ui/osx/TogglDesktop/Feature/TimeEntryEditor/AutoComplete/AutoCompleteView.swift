//
//  AutoCompleteView.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/25/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

final class AutoCompleteViewWindow: NSWindow {

    // MARK: Private
    private let topPadding: CGFloat = 5.0
    override var canBecomeMain: Bool {
        return true
    }
    override var canBecomeKey: Bool {
        guard let contentView = contentView else {
            return false
        }
        switch contentView {
        case is ProjectCreationView:
            return true
        default:
            return false
        }
    }

    // MARK: Init

    init(view: NSView) {
        super.init(contentRect: view.bounds,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: true)
        contentView = view
    }

    func layoutFrame(with textField: NSTextField, height: CGFloat) {
        guard let window = textField.window else { return }
        let size = textField.frame.size

        // Convert
        var location = CGPoint.zero
        let point = textField.superview!.convert(textField.frame.origin, to: nil)
        if #available(OSX 10.12, *) {
            location = window.convertPoint(toScreen: point)
        } else {
            // Fallback on earlier versions
        }
        location.y -= topPadding
        setFrame(CGRect(x: 0, y: 0, width: size.width, height: height), display: false)
        setFrameTopLeftPoint(location)
    }

    func cancel() {
        parent?.removeChildWindow(self)
        orderOut(nil)
    }
}

protocol AutoCompleteViewDelegate: class {

    func didTapOnCreateButton()
}

final class AutoCompleteView: NSView {

    // MARK: OUTLET

    @IBOutlet weak var tableView: KeyboardTableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var createNewItemBtn: CursorButton!
    @IBOutlet weak var createNewItemContainerView: NSBox!
    @IBOutlet weak var horizontalLine: NSBox!

    // MARK: Variables

    weak var delegate: AutoCompleteViewDelegate?
    private var dataSource: AutoCompleteViewDataSource!

    // MARK: Public

    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
    }

    func prepare(with dataSource: AutoCompleteViewDataSource) {
        self.dataSource = dataSource
        self.dataSource.prepare(self)
    }

    func filter(with text: String) {
        dataSource.filter(with: text)
    }

    func update(height: CGFloat) {
        tableViewHeight.constant = height
    }

    func setCreateButtonSectionHidden(_ isHidden: Bool) {
        horizontalLine.isHidden = isHidden
        createNewItemContainerView.isHidden = isHidden
    }

    @IBAction func createNewItemOnTap(_ sender: Any) {
        delegate?.didTapOnCreateButton()
    }
}

// MARK: Private

extension AutoCompleteView {

    fileprivate func initCommon() {
        createNewItemBtn.cursor = .pointingHand
        tableView.keyUpOnPress = {[weak self] key in
            switch key {
            case .enter,
                 .returnKey:
                self?.dataSource.selectSelectedRow()
            default:
                break
            }
        }
    }
}
