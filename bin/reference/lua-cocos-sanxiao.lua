require "Cocos2d"
require "Cocos2dConstants"
require "src.SushiSprite"

Sushi = require("SushiSprite")

local PlayerLayer = class("PlayerLayer", function()
    return cc.Layer:create()
end)

function PlayerLayer:createScene()
    local scene = cc.Scene:create();
    local layer = PlayerLayer:create();
    scene:addChild(layer);
    return scene
end

function PlayerLayer.create()
    local layer = PlayerLayer.new();
    layer:init();
    return layer;
end

function PlayerLayer:ctor()
    self.spriteSheet = nil
    self.m_isNeedFillVacancies = false
    self.m_isAnimationing = true
    self.m_isTouchEnable = true
    self.m_srcSushi = nil
    self.m_destSushi = nil 
    self.m_movingVertical = true
    self.m_hasCanSushi = true
end

function PlayerLayer:init() 
    math.randomseed(os.time())
    
    --创建游戏背景
    local winSize = cc.Director:getInstance():getWinSize()
    local background = cc.Sprite:create("background.png")
    background:setAnchorPoint(0,1)
    background:setPosition(0,winSize.height)
    self:addChild(background)
    
    --初始化寿司精灵表单
    cc.SpriteFrameCache:getInstance():addSpriteFrames("sushi.plist","sushi.pvr.ccz")
    
    --初始化矩阵的宽和高
    self.m_width = 5
    self.m_height = 7
    
    --初始化寿司矩阵左下角的点
    self.m_matrixLeftBottomX = (background:getContentSize().width - Sushi.getContentWidth() * self.m_width - (self.m_width - 1) * 6) / 2
    self.m_matrixLeftBottomY = 0
    
    --初始化数组
    self.m_matrix = {}

    --初始化寿司矩阵
    self:initMatrix();
    
    --每帧刷新
    local function update(delta)
        self:update(delta)
    end
    self:scheduleUpdateWithPriorityLua(update,1)
    
    --加事件监听器
    local function onTouchBegan(touch, event)
        return self:OnTouchBegan(touch, event)
    end
    local function onTouchMoved(touch, event)
        self:onTouchMoved(touch, event)
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function PlayerLayer:OnTouchBegan(touch, event)
    local target = event:getCurrentTarget()

    local locationInNode = target:convertToNodeSpace(touch:getLocation())
    local s = target:getContentSize()
    local rect = cc.rect(0, 0, s.width, s.height)

    if cc.rectContainsPoint(rect, locationInNode) then
        print(string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y))
        target:setOpacity(180)
        
        self.m_srcSushi = nil
        self.m_destSushi = nil
        if self.m_isTouchEnable then
            local location = touch:getLocation()
            self.m_srcSushi = self:sushiOfPoint(location)
        end
        return self.m_isTouchEnable;
    end
    return false
end

function PlayerLayer:onTouchMoved(touch, event)
    if not self.m_isTouchEnable or not self.m_srcSushi then
        return
    end
    local row = self.m_srcSushi:getRow()
    local col = self.m_srcSushi:getCol()
    local location = touch:getLocation()
    local halfSushiWidth = self.m_srcSushi:getContentSize().width * 0.5
    local halfSushiHeight = self.m_srcSushi:getContentSize().height * 0.5
    --检查是否碰触上方寿司
    local upRect = cc.rect(
        self.m_srcSushi:getPositionX() - halfSushiWidth,
        self.m_srcSushi:getPositionY() + halfSushiHeight,
        self.m_srcSushi:getContentSize().width,
        self.m_srcSushi:getContentSize().height
    )
    if cc.rectContainsPoint(upRect,location) then
        row = row + 1
        if row <= self.m_height then
            self.m_destSushi = self.m_matrix[(row - 1) * self.m_width + col]
        end
        self.m_movingVertical = true
        self:swapSushi()
        return
    end
    --检查是否碰触左边寿司
    upRect = cc.rect(
        self.m_srcSushi:getPositionX() - 3 * halfSushiWidth,
        self.m_srcSushi:getPositionY() - halfSushiHeight,
        self.m_srcSushi:getContentSize().width,
        self.m_srcSushi:getContentSize().height
    )
    if cc.rectContainsPoint(upRect,location) then
        col = col - 1
        if col >= 1 then
            self.m_destSushi = self.m_matrix[(row - 1) * self.m_width + col]
        end
        self.m_movingVertical = false
        self:swapSushi()
        return
    end
    --检查是否碰触右边的寿司
    upRect = cc.rect(
        self.m_srcSushi:getPositionX() + halfSushiWidth,
        self.m_srcSushi:getPositionY() - halfSushiHeight,
        self.m_srcSushi:getContentSize().width,
        self.m_srcSushi:getContentSize().height
    )
    if cc.rectContainsPoint(upRect,location) then
        col = col + 1
        if col <= self.m_width then
            self.m_destSushi = self.m_matrix[(row - 1) * self.m_width + col]
        end
        self.m_movingVertical = false
        self:swapSushi()
        return
    end
    --检查是否碰触下方的寿司
    upRect = cc.rect(
        self.m_srcSushi:getPositionX() - halfSushiWidth,
        self.m_srcSushi:getPositionY() - 3 * halfSushiHeight,
        self.m_srcSushi:getContentSize().width,
        self.m_srcSushi:getContentSize().height
    )
    if cc.rectContainsPoint(upRect,location) then
        row = row - 1
        if row >= 1 then
            self.m_destSushi = self.m_matrix[(row - 1) * self.m_width + col]
        end
        self.m_movingVertical = true
        self:swapSushi()
        return
    end
end

function PlayerLayer:sushiOfPoint(location)
    local sushi
    local rect = cc.rect(0,0,0,0)
    local length = self.m_width * self.m_height
    for i=1, length do
    	sushi = self.m_matrix[i]
    	if sushi then
           rect.x = sushi:getPositionX() - sushi:getContentSize().width * 0.5
           rect.y = sushi:getPositionY() - sushi:getContentSize().height * 0.5
           rect.width = sushi:getContentSize().width
           rect.height = sushi:getContentSize().height
    	   if cc.rectContainsPoint(rect,location) then
    	       return sushi
    	   end
    	end
    end
    return nil
end

function PlayerLayer:swapSushi()
    self.m_isAnimationing = true
    self.m_isTouchEnable = false;
    if not self.m_srcSushi or not self.m_destSushi then
        self.m_movingVertical = true
        return
    end
    local srcX,srcY = self.m_srcSushi:getPosition()
    local destX,destY = self.m_destSushi:getPosition()
    local time = 0.2
    
    --交换m_srcSushi与m_destSushi在寿司矩阵中的行、列号
    self.m_matrix[(self.m_srcSushi:getRow() - 1) * self.m_width + self.m_srcSushi:getCol()] = self.m_destSushi
    self.m_matrix[(self.m_destSushi:getRow() - 1) * self.m_width + self.m_destSushi:getCol()] = self.m_srcSushi
    local tmpRow = self.m_srcSushi:getRow()
    local tmpCol = self.m_srcSushi:getCol()
    self.m_srcSushi:setRow(self.m_destSushi:getRow())
    self.m_srcSushi:setCol(self.m_destSushi:getCol())
    self.m_destSushi:setRow(tmpRow)
    self.m_destSushi:setCol(tmpCol)
    
    --检测交换后的m_srcSushi和m_destSushi在横纵方向上是否满足消除条件
    if self:checkSushi(self.m_srcSushi) or self:checkSushi(self.m_destSushi) then
        --满足条件交换
        local test = cc.Sprite:create()
        self.m_srcSushi:stopAllActions()
        self.m_destSushi:stopAllActions()
        self.m_srcSushi:runAction(cc.MoveTo:create(time,{x=destX,y=destY}))
        self.m_destSushi:runAction(cc.MoveTo:create(time,{x=srcX,y=srcY}))
        return
    else
        --不满足消除条件时，交换回寿司本身在矩阵中的行、列号
        self.m_matrix[(self.m_srcSushi:getRow() - 1) * self.m_width + self.m_srcSushi:getCol()] = self.m_destSushi
        self.m_matrix[(self.m_destSushi:getRow() - 1) * self.m_width + self.m_destSushi:getCol()] = self.m_srcSushi
        tmpRow = self.m_srcSushi:getRow()
        tmpCol = self.m_srcSushi:getCol()
        self.m_srcSushi:setRow(self.m_destSushi:getRow())
        self.m_srcSushi:setCol(self.m_destSushi:getCol())
        self.m_destSushi:setRow(tmpRow)
        self.m_destSushi:setCol(tmpCol)
        --顺序执行一对往返的MoveTo动作
        self.m_srcSushi:stopAllActions()
        self.m_destSushi:stopAllActions()
        self.m_srcSushi:runAction(cc.Sequence:create(
            cc.MoveTo:create(time, {x=destX,y=destY}),
            cc.MoveTo:create(time, {x=srcX,y=srcY})))
        self.m_destSushi:runAction(cc.Sequence:create(
            cc.MoveTo:create(time, {x=srcX,y=srcY}),
            cc.MoveTo:create(time, {x=destX,y=destY})))
    end
end

function PlayerLayer:update(delta)
    if self.m_isAnimationing then
    	self.m_isAnimationing = false  
    	local length = self.m_height * self.m_width
    	for i=1, length do
    		local sushi = self.m_matrix[i]
    		if sushi and sushi:getNumberOfRunningActions()>0 then
    			self.m_isAnimationing = true
    			break
    		end
    	end
    end
    
    self.m_isTouchEnable = not self.m_isAnimationing
    
    if not self.m_isAnimationing then
        if self.m_isNeedFillVacancies then
            self:fillVacancies()
            self.m_isNeedFillVacancies = false
        else
            self:checkAndRemoveChain()
        end
    end
end

function PlayerLayer:checkAndRemoveChain()
    local length = self.m_height * self.m_width
    local sushi
    --reset ignore flag
    for i=1, length do
    	sushi = self.m_matrix[i]
    	if sushi then
            sushi:setIgnoreCheck(false)
    	end
    end
    --check chain
    for i=1, length do
        sushi = self.m_matrix[i]
        if sushi and not sushi:getIsNeedRemove() and not sushi:getIgnoreCheck() then 
            local longerList = self:checkSushi(sushi,sushi:getRow(),sushi:getCol())
            if longerList then
                local isSetedIgnoreCheck = false
                for key, sushi in ipairs(longerList) do
                    if sushi then  
                        if table.maxn(longerList) > 3 and (sushi == self.m_srcSushi or sushi == self.m_destSushi) then
                            isSetedIgnoreCheck = true
                            sushi:setIgnoreCheck(true)
                            sushi:setIsNeedRemove(false)
                            if self.m_movingVertical then
                                sushi:setDisplayMode(DISPLAY_MODE_VERTICAL)
                            else
                                sushi:setDisplayMode(DISPLAY_MODE_HORIZONTAL)
                            end
                        else
                            self:markRemove(sushi)
                        end
                    end
                end 
                if not isSetedIgnoreCheck and table.maxn(longerList) > 3 then
                    sushi:setIgnoreCheck(true)
                    sushi:setIsNeedRemove(false)
                    if self.m_movingVertical then
                        sushi:setDisplayMode(DISPLAY_MODE_VERTICAL)
                    else
                        sushi:setDisplayMode(DISPLAY_MODE_HORIZONTAL)
                    end
                end
            end
        end
    end
    self:removeSuShi()
end

function PlayerLayer:markRemove(sushi)
    if sushi:getIsNeedRemove() then return end
    if sushi:getIgnoreCheck() then return end
    
    sushi:setIsNeedRemove(true)
    local tmp
    if sushi:getDisplayMode() == DISPLAY_MODE_VERTICAL then
        for row=1,self.m_height do
            tmp = self.m_matrix[(row-1)*self.m_width + sushi:getCol()]
            if tmp and tmp ~= sushi then
                if tmp:getDisplayMode() == DISPLAY_MODE_NORMAL then
                    tmp:setIsNeedRemove(true)
                else
                    self.markRemove(tmp)
                end 
            end
        end
    elseif sushi:getDisplayMode() == DISPLAY_MODE_HORIZONTAL then
        for col=1,self.m_width do
            tmp = self.m_matrix[(sushi:getRow()-1)*self.m_width + col]
            if tmp and tmp ~= sushi then
                if tmp:getDisplayMode() == DISPLAY_MODE_NORMAL then
                    tmp:setIsNeedRemove(true)
                else
                    self.markRemove(tmp)
                end 
            end
        end
    end
end

function PlayerLayer:getColChain(sushi)
    local chainList = {}
    table.insert(chainList,1,sushi)
    local neighborCol = sushi:getCol() - 1
    while neighborCol >= 1 do
        local neighborSushi = self.m_matrix[(sushi:getRow() - 1) * self.m_width + neighborCol]
        if neighborSushi and neighborSushi:getImgIndex() == sushi:getImgIndex() then
        	table.insert(chainList,1,neighborSushi)
        	neighborCol = neighborCol - 1
        else
            break
        end
    end
    neighborCol = sushi:getCol() + 1
    while neighborCol <= self.m_width do
        local neighborSushi = self.m_matrix[(sushi:getRow() - 1) * self.m_width + neighborCol]
        if neighborSushi and neighborSushi:getImgIndex() == sushi:getImgIndex() then
            table.insert(chainList,1,neighborSushi)
            neighborCol = neighborCol + 1
        else
            break
        end
    end
    return chainList
end

function PlayerLayer:getRowChain(sushi)
    local chainList = {}
    table.insert(chainList,1,sushi)
    local neighborRow = sushi:getRow() - 1
    while neighborRow >= 1 do
        local neighborSushi = self.m_matrix[(neighborRow - 1) * self.m_width + sushi:getCol()]
        if neighborSushi and neighborSushi:getImgIndex() == sushi:getImgIndex() then
            table.insert(chainList,1,neighborSushi)
            neighborRow = neighborRow - 1
        else
            break
        end
    end
    neighborRow = sushi:getRow() + 1
    while neighborRow <= self.m_height do
        local neighborSushi = self.m_matrix[(neighborRow - 1) * self.m_width + sushi:getCol()]
        if neighborSushi and neighborSushi:getImgIndex() == sushi:getImgIndex() then
            table.insert(chainList,1,neighborSushi)
            neighborRow = neighborRow + 1
        else
            break
        end
    end
    return chainList
end

function PlayerLayer:removeSuShi()
    self.m_isAnimationing = true
    local length = self.m_height * self.m_width
    for i=1, length do
    	local sushi = self.m_matrix[i]
        if sushi and sushi:getIsNeedRemove() then 
            self.m_isNeedFillVacancies = true;
            self:explodeSushi(sushi);
    	end
    end
--    if not self.m_isNeedFillVacancies then
--        for i=1, length do
--            local sushi = self.m_matrix[i]
--            if sushi then 
--                self.m_isNeedFillVacancies = true;
--                sushi:setIsNeedRemove(true) 
--                self:explodeSushi(sushi);
--            end
--        end
--    end
end

function PlayerLayer:checkSushi(sushi)
    local colChainList = self:getColChain(sushi)
    local rowChainList = self:getRowChain(sushi)
    local longerList
    if table.maxn(colChainList) > table.maxn(rowChainList) then
        longerList = colChainList
    else
        longerList = rowChainList
    end
    if table.maxn(longerList) >= 3 then 
        return longerList
    end
    return nil
end

function PlayerLayer:explodeSushi(sushi)
    local time = 0.3
    --寿司action逐渐变小
    local function actionEndCallback()
        self.m_matrix[(sushi:getRow() - 1) * self.m_width + sushi:getCol()] = nil;
        sushi:removeFromParentAndCleanup();
    end
    sushi:stopAllActions()
    sushi:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(time,0.0),
            cc.CallFunc:create(actionEndCallback),
            nil
       )
    )
    
    --粒子特效
    local particleStars = cc.ParticleSystemQuad:create("stars.plist")
    particleStars:setAutoRemoveOnFinish(true)
    particleStars:setBlendAdditive(false)
    particleStars:setPosition(sushi:getPosition())
    particleStars:setScale(0.3)
    self:addChild(particleStars, 20)

    --圆圈特效
    local circleSprite = cc.Sprite:create("circle.png");
    self:addChild(circleSprite, 10);
    circleSprite:setPosition(sushi:getPosition());
    circleSprite:setScale(0);
    circleSprite:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(time, 1.0),    
            cc.CallFunc:create(circleSprite.removeFromParentAndCleanup),
            nil
        )
    )
end

function PlayerLayer:fillVacancies()
    self.m_isAnimationing = true
    self.m_movingVertical = true

    local size = cc.Director:getInstance():getWinSize()
    local colEmptyInfo = {}
    local removedSushiOfCol
    --让空缺处上面的精灵向下落
    for col=1, self.m_width do
        removedSushiOfCol  = 0
        for row=1, self.m_height do
            local sushi = self.m_matrix[(row - 1) * self.m_width + col]
            if not sushi then
                removedSushiOfCol = removedSushiOfCol + 1
            elseif removedSushiOfCol  > 0 then
                local newRow = row - removedSushiOfCol
                self.m_matrix[(newRow - 1) * self.m_width + col] = sushi
                self.m_matrix[(row - 1) * self.m_width + col] = nil
                local startx,starty = sushi:getPosition()
                local endx,endy = self:positionOfItem(newRow, col)
                local speed = (starty - endy) / size.height
                sushi:stopAllActions()
                sushi:runAction(cc.MoveTo:create(speed,{x=endx,y=endy}))
                sushi:setRow(newRow)
        	end
        end
        -- 记录col列上空缺数
        colEmptyInfo[col] = removedSushiOfCol;
    end
    
    --创建新的寿司精灵并让它落到上方空缺的位置
    for col=1, self.m_width do
        for row=self.m_height - colEmptyInfo[col] + 1, self.m_height do
            self:createAndDropSushi(row, col)
        end
    end
end

function PlayerLayer:initMatrix()
    for row=1,self.m_height do
        for col=1,self.m_width do
            self:createAndDropSushi(row, col)
        end
    end 
end

function PlayerLayer:createAndDropSushi(row, col)
    local size = cc.Director:getInstance():getWinSize()

    local sushi =  Sushi.create(row,col)

    --创建并执行下落动画
    self.m_isAnimationing = true
    local endx,endy = self:positionOfItem(row, col);
    local startx = endx
    local starty = endy + size.height / 2
    local speed = starty / (1.5 * size.height);
    sushi:setPosition(startx,starty)
    local vec2_table = {x=endx, y=endy};
    sushi:stopAllActions()
    sushi:runAction(cc.MoveTo:create(speed,vec2_table))
    self:addChild(sushi)

    --给指定位置的数组赋值
    self.m_matrix[(row - 1) * self.m_width + col] = sushi;
end

function PlayerLayer:positionOfItem(row, col)
    local x = self.m_matrixLeftBottomX + (Sushi.getContentWidth() + 6) * (col - 1) + Sushi.getContentWidth() / 2;
    local y = self.m_matrixLeftBottomY + (Sushi.getContentWidth() + 6) * (row - 1) + Sushi.getContentWidth() / 2;
    return x,y;
end

return PlayerLayer