//
//  ViewController.swift
//  BCMarkdownDemo
//
//  Created by lang on 07/02/2018.
//  Copyright © 2018 Beary Innovative. All rights reserved.
//

import UIKit
import BCMarkdown

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = Bundle.main.url(forResource: "test", withExtension: "md")!
        let document = try? String(contentsOf: url)
        let render = AttributedStringRenderer(document: Document(string: document!, option: [.hardBreaks])!, textAttributesProvider: TextAttributes())
        let str = render.render()
        textView.attributedText = str
        print(str)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

