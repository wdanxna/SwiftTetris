//
//  Tile.swift
//  Tetris
//
//  Created by drakeDan on 3/5/15.
//  Copyright (c) 2015 bravo. All rights reserved.
//

import UIKit
import SpriteKit

struct tileOrient {
    let up : [[Int]]
    let right: [[Int]]
    let down: [[Int]]
    let left : [[Int]]
}

struct tileType {

    static let T = tileOrient(
        up:    [[0,1,0,0],
                [1,1,1,0],
                [0,0,0,0],
                [0,0,0,0]],
        
        right: [[0,1,0,0],
                [0,1,1,0],
                [0,1,0,0],
                [0,0,0,0]],
        
        down:  [[0,0,0,0],
                [1,1,1,0],
                [0,1,0,0],
                [0,0,0,0]],
        
        left:  [[0,1,0,0],
                [1,1,0,0],
                [0,1,0,0],
                [0,0,0,0]])
    
    
    static let L = tileOrient(
        up:    [[0,1,0,0],
                [0,1,0,0],
                [0,1,1,0],
                [0,0,0,0]],
        
        right: [[0,0,0,0],
                [1,1,1,0],
                [1,0,0,0],
                [0,0,0,0]],
        
        down:  [[1,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [0,0,0,0]],
        
        left:  [[0,0,1,0],
                [1,1,1,0],
                [0,0,0,0],
                [0,0,0,0]]
    )
    
    static let N = tileOrient(
        up:    [[0,1,0,0],
                [1,1,0,0],
                [1,0,0,0],
                [0,0,0,0]],
        
        right: [[1,1,0,0],
                [0,1,1,0],
                [0,0,0,0],
                [0,0,0,0]],
        
        down:  [[0,1,0,0],
                [1,1,0,0],
                [1,0,0,0],
                [0,0,0,0]],
        
        left:  [[1,1,0,0],
                [0,1,1,0],
                [0,0,0,0],
                [0,0,0,0]])
    
    
    static let I = tileOrient(
        up:    [[0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0]],
        
        right: [[0,0,0,0],
                [1,1,1,1],
                [0,0,0,0],
                [0,0,0,0]],
        
        down:  [[0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0]],
        
        left:  [[0,0,0,0],
                [1,1,1,1],
                [0,0,0,0],
                [0,0,0,0]])
    
}




class Tile: SKSpriteNode {
    var isCurrent = false
    var style: SKColor {
        didSet{
            self.color = self.style
        }
    }
    var x = 0, y = 0
    
    init(style: SKColor, position:(x:Int, y:Int), size:CGSize){
        self.style = style
        super.init(texture: nil, color: style, size: size)
//        self.position = CGPointMake(position.x, position.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.style = tileStyle.None
        super.init()
    }
    
}
