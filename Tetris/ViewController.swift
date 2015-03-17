//
//  ViewController.swift
//  Tetris
//
//  Created by drakeDan on 3/4/15.
//  Copyright (c) 2015 bravo. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    var _myScene: MyScene!
    
    func gameStart() {
        _myScene.reset()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _myScene = MyScene(size: skView.frame.size)
        skView.presentScene(_myScene)
        gameStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

