//
//  LegalViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import WebKit


class LegalViewController: UIViewController {
    
    private var webView: WKWebView!
    
    override func loadView() {
        let view = UIView()
        
        let header = UILabel()
        header.text = "Legal"
        header.font = UIFont(ottoStyle: .roman, size: 18)
        header.textColor = .white
        
        let arrow = UIButton()
        arrow.setImage(#imageLiteral(resourceName: "arrow_left_white"), for: .normal)
        arrow.adjustsImageWhenHighlighted = false
        arrow.addTarget(
            self,
            action: #selector(LegalViewController.goBack),
            for: .touchUpInside
        )
        
        let webView = WKWebView()
        self.webView = webView
        
        header.translatesAutoresizingMaskIntoConstraints = false
        arrow.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(header)
        view.addSubview(arrow)
        view.addSubview(webView)
        
        let views = ["header": header, "arrow": arrow, "web": webView]
        
        let verti = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-40-[header]-10-[web]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let headerCenterX = NSLayoutConstraint(
            item: header,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        let arrowHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[arrow(==50)]",
            options: [],
            metrics: nil,
            views: views
        )
        let arrowHeight = NSLayoutConstraint(
            item: arrow,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 50.0
        )
        let arrowCenterY = NSLayoutConstraint(
            item: arrow,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: header,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0
        )
        let webHoriz = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[web]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        
        NSLayoutConstraint.activate(verti)
        NSLayoutConstraint.activate([headerCenterX])
        NSLayoutConstraint.activate(arrowHoriz)
        NSLayoutConstraint.activate([arrowCenterY, arrowHeight])
        NSLayoutConstraint.activate(webHoriz)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .petBackground
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        
        // FIXME: Change this legal url later
        
        guard let url = URL(string: "https://github.com/dilyar85/CS160-Group-Project") else {
            return
        }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    @objc private func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension LegalViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix("http://") ||
                url.absoluteString.hasPrefix("https://") ||
                url.absoluteString.hasPrefix("mailto://") {
                
                UIApplication.shared.openURL(url)
            }
        }
        return nil
    }
    
}
