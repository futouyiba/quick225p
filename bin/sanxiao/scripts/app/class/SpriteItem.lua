local SpriteItem = class("SpriteItem", function(batchNode, row, col, imageIndex)
    math.newrandomseed()
    imageIndex = imageIndex or math.round(math.random()*1000)%5 + 1
    local item = display.newSprite("#dialogue_portrait_"  .. imageIndex .. '.jpg')
    item:setScale(0.1)
    item.m_imageIndex, item.m_row, item.m_col = imageIndex, row, col
    item.m_batchNode = batchNode
    item.m_isActive = false
    return item end
)

function SpriteItem:setActive(active)
    self.m_isActive = active
 
    local frame
    if (active) then
     --   frame = display.newSpriteFrame("#dialogue_portrait_"  .. self.m_imageIndex .. '_alpha_mask.png')
     frame = display.newSpriteFrame("#dialogue_portrait_"  .. self.m_imageIndex .. '.png')
    else
        frame = display.newSpriteFrame("#dialogue_portrait_"  .. self.m_imageIndex .. '.jpg')
    end
 
    self:setDisplayFrame(frame)
 
    if (active) then
        self:stopAllActions()
        local scaleTo1 = CCScaleTo:create(0.1, 1.1)
        local scaleTo2 = CCScaleTo:create(0.05, 1.0)
        self:runAction(transition.sequence({scaleTo1, scaleTo2}))
    end
end

function SpriteItem.getContentWidth() 
<<<<<<< HEAD
	return 400*scale
=======
	return 37
>>>>>>> origin/master
end


return SpriteItem