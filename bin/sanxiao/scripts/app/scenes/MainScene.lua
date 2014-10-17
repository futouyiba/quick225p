local ITEM_GAP=0

local SpriteItem=import("..class.spriteItem")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
 
 --   display.newSprite("background.png"):pos(display.cx,display.cy):addTo(self)
    display.addSpriteFramesWithFile("newsanxiao.plist", "newsanxiao.png")
    print("newsanxiao loaded!")
    self.m_level = 1
    self.m_rowLength = 10
    self.m_colLength = 6
    self.m_goalScore = 100
    self.m_leftMovements = 10
    self.m_levelScore = 0
 
    self.m_matrixLeftBottomX = (display.width - SpriteItem.getContentWidth() * self.m_colLength - (self.m_colLength - 1) * ITEM_GAP) / 2
    self.m_matrixLeftBottomY = (display.height - SpriteItem.getContentWidth() * self.m_rowLength - (self.m_rowLength - 1) * ITEM_GAP) / 2
 
    -- 创建BatchNode
    self.m_batchNode = display.newBatchNode("newsanxiao.png")
    self:addChild(self.m_batchNode)
 
    -- init array
    local arraySize = self.m_rowLength * self.m_colLength
    self.m_matrix = {}
    self.m_acticves = {}
 
    -- active score lable
    self.m_labelActiveScore = ui.newTTFLabel({text="", font="", size=26})
    self.m_labelActiveScore:setColor(display.COLOR_WHITE)
    self.m_labelActiveScore:setPosition(ccp(display.width / 2, 55))
    self:addChild(self.m_labelActiveScore)
 
    local touchLayer = display.newLayer()
    touchLayer:setTouchEnabled(true)
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        print(event.name, event.x, event.y)
--        if(event.name == "ended") then
            self:onTouch(event)
 --       else
--            return true
 --       end
    end)
    self:addChild(touchLayer)
    self:initMartix()
    self:scheduleUpdate()
--    self.m_matrix[1]:setActive(true)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
--【】可以看出quick当中这个函数是不一定叫update的
    	return self:update1(dt)
    	end)
end

function MainScene:onEnter()
    self.m_matrix[1]:setActive(true)
end

function MainScene:onExit()
end

function MainScene:update1(dt)
--	print(dt)
	local m_isAnimationing=true
	for k,v in pairs(self.m_matrix) do
		if (v~=nil and v:getNumberOfRunningActions()>0)
--		if v:getNumberOfRunningActions()>0
			then m_isAnimationing=false
		end
	end
	if not m_isAnimationing then
--		self:checkAndRemoveChain()
	end
end

function MainScene:onTouch(event)
    if event.name=="began" then
        self.srcSushiKey,self.m_srcSushi=self:sushiOfPoint(event.x, event.y)
        if self.m_srcSushi==nil then
            print("touched empty space")
            return false
        else
            self.m_srcSushi:setActive(true)
            return true
        end
    end
    if event.name=="moved" then
        return
    end
    if event.name=="ended" then
        self.destSushiKey,self.m_destSushi=self:sushiOfPoint(event.x, event.y)
        if self.m_srcSushi==self.m_destSushi then
            self.m_srcSushi:setActive(false)
            return
        else
            self:exchangeSushi()
        end

    end
end

function MainScene:exchangeSushi()
--先不加矩阵中交换、属性m row和列的交换
    local srcX,srcY = self.m_srcSushi:getPosition()
    local destX,destY = self.m_destSushi:getPosition()
        self.m_srcSushi:stopAllActions()
        self.m_destSushi:stopAllActions()
        self.m_srcSushi:runAction(cc.MoveTo:create(time,{x=destX,y=destY}))
        self.m_destSushi:runAction(cc.MoveTo:create(time,{x=srcX,y=srcY}))

end


--先用更费资源的方式获取，以后有余力时再重构.其实只要用数学公式算就行了
function MainScene:sushiOfPoint(x,y)
    for k,v in pairs(self.m_matrix) do
        if v:getCascadeBoundingBox():containsPoint(cc.PointMake(x,y)) then
            return k,v
        end
    end
    return nil

end


function MainScene:initMartix()
	math.newrandomseed()
    for row = 0, self.m_rowLength-1 do
        for col = 1, self.m_colLength do
            if (1 == row and 1 == col) then
                self:createAndDropItem(row, col)
            else
                self:createAndDropItem(row, col)
            end
        end
    end
end
 
function MainScene:createAndDropItem(row, col, imgIndex)
    local newItem = SpriteItem.new(self.m_batchNode, row, col, imgIndex)
--    print(newItem.m_isActive)  【】说明不用生成synthesis函数，直接用lua  metatable的属性读取就可以了
    local endPosition = self:positionOfItem(row, col)
    local startPosition = ccp(endPosition.x, endPosition.y + display.height / 2)
    newItem:setPosition(startPosition)
    local speed = startPosition.y / (2 * display.height)
    newItem:runAction(CCMoveTo:create(speed, endPosition))
    self.m_matrix[row * self.m_colLength + col] = newItem
    self.m_batchNode:addChild(newItem)
end

function MainScene:positionOfItem(row, col)
    local x = self.m_matrixLeftBottomX + (SpriteItem.getContentWidth() + ITEM_GAP) * (col-1) + SpriteItem.getContentWidth() / 2
    local y = self.m_matrixLeftBottomY + (SpriteItem.getContentWidth() + ITEM_GAP) * (row) + SpriteItem.getContentWidth() / 2
    return ccp(x, y)
end




return MainScene
