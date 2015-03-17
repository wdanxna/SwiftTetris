//
//  MyScene.swift
//  Tetris
//
//  Created by drakeDan on 3/4/15.
//  Copyright (c) 2015 bravo. All rights reserved.
//

import UIKit
import SpriteKit
struct tileStyle {
    static let None = SKColor.clearColor()
    static let Red = SKColor.redColor()
    static let Blue = SKColor.blueColor()
    static let Yellow = SKColor.yellowColor()
    static let Green = SKColor.greenColor()
}

struct tileSize {
    static let width:CGFloat = 30
    static let height:CGFloat = 30
}

class MyScene: SKScene {
    
    let boardWidth = 10
    let boardHeight = 20
    
    var board = [[Tile]]()
    let updateDT = 0.3
    var lastUpdateTime: NSTimeInterval = 0.0
    var updateTimer : NSTimeInterval = 0.0
    var needSpawnNewTile = true
    var currentTile = [(Int, Int)]()
    var currentTileStyle = tileStyle.None
    var currentOrientation = 0
    var currentShape = 0
    var controlIndex = 0
    
    var lastXIndex = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size aSize: CGSize) {
        super.init(size: aSize)
        
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        let tapGR = UITapGestureRecognizer(target: self, action: Selector("tap:"))
        let panGR = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
        self.view?.addGestureRecognizer(tapGR)
        self.view?.addGestureRecognizer(panGR)
        
        var left = UIButton(frame: CGRectMake(70,self.view!.frame.size.height/2-50, 80, 80))
        left.backgroundColor = UIColor.whiteColor()
        left.titleLabel!.text = "<--" //not working, don't know why
        left.addTarget(self, action: Selector("left:"), forControlEvents: UIControlEvents.TouchUpInside)
        left.alpha = 0.5
        self.view!.addSubview(left)
        
        var right = UIButton(frame: CGRectMake(190, self.view!.frame.size.height/2-50, 80, 80))
        right.backgroundColor = UIColor.whiteColor()
        right.titleLabel!.text = "-->"
        right.addTarget(self, action: Selector("right:"), forControlEvents: UIControlEvents.TouchUpInside)
        right.alpha = 0.5
        self.view!.addSubview(right)
    }
    
    func left(sender: UIButton) {
        self.shiftTile(-1)
    }
    
    func right(sender:UIButton) {
        self.shiftTile(1)
    }
    
    func pan(gr:UIPanGestureRecognizer) {
        let p = gr.translationInView(self.view!)
        if (gr.state == UIGestureRecognizerState.Began) {
            gr.setTranslation(CGPointZero, inView: self.view!)
        }
        let n = Int(p.x / 30)

        if (n < -1) {
            println("left: \(n)")
            shiftTile(-1)
        }
        else if (n > 1) {
            println("right: \(n)")
            shiftTile(1)
        }
    }
    
    func shiftTile(n:Int)->Bool {
        var newTiles = [(Int,Int)]()
        for (x,y) in currentTile {
            let newx = x + n
            if (newx < 0 || newx > boardWidth-1 || (!board[y][newx].isCurrent && board[y][newx].style != tileStyle.None)) {
                return false
            }
            newTiles.append((newx, y))
        }
        
        for (x,y) in currentTile {
            board[y][x].style = tileStyle.None
            board[y][x].isCurrent = false
        }
        
        for (x,y) in newTiles {
            board[y][x].style = currentTileStyle
            board[y][x].isCurrent = true
        }
        currentTile = newTiles
        if (needSpawnNewTile && fallable()) {
            needSpawnNewTile = false
        }
        return true
    }
    
    func tap(gr:UITapGestureRecognizer) {
        rotateCurrentShape()
    }
    
    func rotateCurrentShape() {
        let shape = getShape(currentShape)
        let nextOrientation = (currentOrientation+1) % 4
        let newOrientation = getOrientation(shape, id: nextOrientation)
        let basePos = currentTile[controlIndex]
        var newShape = [(Int, Int)]()
        var isValidShape = true
        var posiableControlIndex = controlIndex
        for (var row = 0; row < 4; row++) {
            for (var col = 0; col < 4; col++) {
                if (newOrientation[row][col] == 1) {
                    let newPos = (basePos.0 + (col - 1), basePos.1 - (row - 1))
                    if (newPos.0 < 0 || newPos.0 > 9 || newPos.1 < 0 || newPos.1 > 19 || (!board[newPos.1][newPos.0].isCurrent && board[newPos.1][newPos.0].style != tileStyle.None)) {
                        isValidShape = false
                    }
                    newShape.append(newPos)
                    if (row == 1 && col == 1) {
                        posiableControlIndex = newShape.count - 1
                    }
                }
            }
        }
        
        if isValidShape {
            //apply rotation
            for (x,y) in currentTile {
                board[y][x].style = tileStyle.None
                board[y][x].isCurrent = false
            }
            
            for (x,y) in newShape {
                board[y][x].style = currentTileStyle
                board[y][x].isCurrent = true
            }

            currentTile = newShape
            currentOrientation = (currentOrientation+1)%4
            controlIndex = posiableControlIndex
//            println("\(currentOrientation)")
            if (needSpawnNewTile && fallable()) {
                needSpawnNewTile = false
            }
        }
    }
    
    func fallable() ->Bool {
        for (x,y) in self.currentTile {
            var newy = y - 1
            if ( newy < 0 || (!board[newy][x].isCurrent && board[newy][x].style != tileStyle.None)) {
                return false
            }
        }
        return true
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        let dt = currentTime - lastUpdateTime
        updateTimer = updateTimer + dt
        
        handleInput()
        
        if (updateTimer > updateDT) {
            // do update
            if (needSpawnNewTile) {
                clearRow()
                let shape = getRandomShape() //seems not so random
                let orientation = getRandomOrientation(shape)
                let style = getRandomStyle() //not random too
                spawnNewTile(orientation, style: style)
                needSpawnNewTile = false
            }
            else {
                if (!fallTile()) {
                    needSpawnNewTile = true
                }
            }
            updateTimer = 0.0
//            println("update!")
        }
        lastUpdateTime = currentTime
    }
    
    func clearRow() {
        var check = [Int:Bool]()
        var dic = [Int:Bool]()
        var clearedRows = [Int]()
        for (x, y) in currentTile {
            if (check[y] == nil) {
                //check the row
                var clear = true
                for i in 0..<boardWidth {
                    if board[y][i].style == tileStyle.None {
                        clear = false
                        break
                    }
                }
                if (clear) {
                    clearedRows.append(y)
                    dic[y] = true
                }
                check[y] = true
            }
        }
        
        if !clearedRows.isEmpty {
            
            clearedRows.sort{$0 < $1}
            
            for row in clearedRows {
                for col in 0..<boardWidth {
                    board[row][col].style = tileStyle.None
                }
            }
            
            var move = 1
            for row in clearedRows[0]+1..<boardHeight {
                if (dic[row] != nil) {
                    move += 1
                }
                else {
                    for col in 0..<boardWidth {
                        if board[row][col].style != tileStyle.None {
                            board[row - move][col].style = board[row][col].style
                            board[row][col].style = tileStyle.None
                        }
                    }
                }
            }
        }
        
    }
    
    func getRandomStyle() -> SKColor {
        switch Int(rand()) % 4 {
        case 0: return tileStyle.Blue
        case 1: return tileStyle.Red
        case 2: return tileStyle.Green
        case 3: return tileStyle.Yellow
        default: return tileStyle.Blue
        }
    }
    
    func getRandomShape() -> tileOrient {
        currentShape = Int(rand()) % 4
        return getShape(currentShape)
    }
    
    func getShape(id:Int) ->tileOrient {
        switch id {
        case 0: return tileType.I
        case 1: return tileType.L
        case 2: return tileType.T
        case 3: return tileType.N
        default: return tileType.I
        }
    }
    
    func getRandomOrientation(shape:tileOrient) ->[[Int]] {
        currentOrientation = Int(rand()) % 4
        return getOrientation(shape,id:currentOrientation)

    }
    
    func getOrientation(shape:tileOrient, id:Int) ->[[Int]] {
        switch id {
        case 0: return shape.up
        case 1: return shape.right
        case 2: return shape.down
        case 3: return shape.left
        default : return shape.up
        }
    }
    
    func fallTile() -> Bool {
        var temp = [(Int,Int)]()
        
        for (x,y) in currentTile {
            var newy = y - 1
            if (newy < 0 || (!board[newy][x].isCurrent && board[newy][x].style != tileStyle.None)) {
                return false
            }
            temp.append((x, newy))
        }
        
        for (x, y) in currentTile {
            board[y][x].style = tileStyle.None
            board[y][x].isCurrent = false
        }
        for (x, y) in temp {
            board[y][x].style = currentTileStyle
            board[y][x].isCurrent = true
        }
        currentTile = temp
        return true
    }
    
    func handleInput() {
        
    }
    
    func spawnNewTile(type:[[Int]], style:SKColor) {
        var randomIndex =  5//Int(rand()) % boardWidth
        currentTileStyle = style
        for (x,y) in currentTile {
            board[y][x].isCurrent = false
        }
        currentTile.removeAll(keepCapacity: true)
        for (var row = 0; row < 4; row++) {
            for (var col = 0; col < 4; col++) {
                if (type[row][col] == 1) {
                    let px = randomIndex + col
                    let py = boardHeight - 1 - row
                    
                    currentTile.append((px, py))
                    if (row == 1 && col == 1) {
                        controlIndex = currentTile.count - 1
                    }
                    board[py][px].style = style
                    board[py][px].isCurrent = true
                }
            }
        }
    }

    func startGame(){
        
    }
    
    func reset() {
        let col = 10
        let row = 20
        for i in 0..<row {
            var acol = [Tile]()
            for j in 0..<col {
                var tile = Tile(style: tileStyle.None,
                    position: (row , col),
                    size: CGSizeMake(tileSize.width, tileSize.height))

                tile.position = CGPointMake(tileSize.width / 2 + CGFloat(j) * tileSize.width,
                    tileSize.height/2 + CGFloat(i) * tileSize.height)
                acol.append(tile)
                self.addChild(tile)
            }
            board.append(acol)
        }
        startGame()
    }
    
}
