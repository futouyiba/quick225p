
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	cc.FileUtils:getInstance():addSearchPath("res/forQuick/")
	local combatScene, width, height = cc.uiloader:load("publish/FightScene.json")
    if combatScene then
        combatScene:setPosition((display.width - width)/2, (display.height - height)/2)
        -- node:setPosition(ccp(0, 0))
        self:addChild(combatScene)
        combatScene:setScale(1.0)
        -- dumpUITree(node)
        -- drawUIRegion(node, scene, 6)
    end
    local hero = cc.uiloader:seekComponents(combatScene, "hero",1)
  	hero:getAnimation():play("run")
  	hero:setScale(0.8)
  	transition.moveBy(hero, {x = 800, y = 0, time = 3.0})
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene

display.newBatchNode(image, capacity)
