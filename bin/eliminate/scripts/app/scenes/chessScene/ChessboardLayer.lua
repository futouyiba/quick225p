--
-- Author: hanxu
-- Date: 2014-03-07 09:24:50
--

require("app.utils.TableUtil")
local ChessCell = import("...model.ChessCell")

local chessBoardBg
local cellLayer
local cellList = {}
local exchangeCells = {}

local  ChessboardLayer = class("ChessboardLayer", function( )
	return display.newLayer()
end)

function ChessboardLayer:ctor()
	self.bg = display.newSprite("bg.jpg")
		:addTo(self)

	chessBoardBg = display.newScale9Sprite("chessBg.png", 0, 0, CCSize(598, 926)):addTo(self)
	chessBoardBg:setCapInsets(CCRect(36, 36, 366, 103))

	cellLayer = display.newLayer():addTo(self)
	local size = chessBoardBg:getContentSize()
	cellLayer:setContentSize(CCSize(size.width, size.height))
	local typeInt = 1
	for i=1,13 do
		for j=1,8 do
			typeInt = math.random(1,18)
			self:createCell(typeInt, i, j,-299+(j-1)*66+64, 463-(i-1)*66-64)
		end
	end

	self:setTouchEnabled(true)
	self:addTouchEventListener(handler(self, self.onTouchHandler))

end

function ChessboardLayer:createCell(type,rowIndex,colIndex, x, y)
	local cell = ChessCell.new(cellLayer,type,rowIndex,colIndex):pos(x, y)
	-- cell:setTouchEnabled(true)
	-- cell:addTouchEventListener(handler(self,self.onTouchHandler))
	cellLayer:addChild(cell)
	cellList[#cellList + 1] = cell
end

local flag = false
local i1 -- 第一个触摸的格子在cellList里面的索引
local i2 -- 第二个触摸的格子在cellList里面的索引
function ChessboardLayer:onTouchHandler(event,x,y)
	if event == "began" then
		flag = true
		exchangeCells[1] = nil
		exchangeCells[2] = nil
		return true
	end

	if event == "moved" then
		if not flag then
			return
		end
		for i=1,#cellList do
				repeat
					if not cellList[i] then
						break
					end
					if cellList[i]:getCascadeBoundingBox():containsPoint(CCPoint(x, y)) then
						-- print("你点击type为"..cellList[i]:getType().."的图片".."在第"..cellList[i]:getRowIndex().."行，第"..cellList[i]:getColIndex().."列")
						if #exchangeCells == 0 then
							exchangeCells[#exchangeCells + 1] = cellList[i]
							i1 = i
							firstRowIndex = cellList[i]:getRowIndex()
							firstColIndex = cellList[i]:getColIndex()
						elseif (#exchangeCells <= 2) and (#exchangeCells == 1) then
							secondRowIndx = cellList[i]:getRowIndex()
							secondColIndex = cellList[i]:getColIndex()
							--x索引方向比较、y索引方向比较
							local absCol = math.abs(secondColIndex - firstColIndex)
							local absRow = math.abs(secondRowIndx - firstRowIndex)
							if (absCol==1 and absRow == 1) or absCol > 1 or absRow > 1 then
								--暂时空着
							elseif (absCol == 1 or absRow == 1) then
								flag = false
								exchangeCells[#exchangeCells + 1] = cellList[i]
								i2 = i
								self:exchangePos(exchangeCells)
							end
						else
							-- print(99999999999)
						end
					end
				until true
		end
	else
		-- --调用交换位置接口(这里可以不写了)
		-- print(#exchangeCells)
		exchangeCells[1] = nil
		exchangeCells[2] = nil
	end
end

function ChessboardLayer:exchangePos(twoCells)
	local firstCellPosX, firstCellPosY = twoCells[1]:getPosition()
	local secondCellPosX, secondCellPosY  = twoCells[2]:getPosition()
	twoCells[1]:runAction(CCMoveTo:create(0.3, CCPoint(secondCellPosX, secondCellPosY)))
	twoCells[2]:runAction(CCMoveTo:create(0.3, CCPoint(firstCellPosX, firstCellPosY)))
	self:exchangeCellIndex(twoCells)
	cellList[i1],cellList[i2] = cellList[i2],cellList[i1]
	self:calculateLinkNum(twoCells[1])
	self:calculateLinkNum(twoCells[2])
	exchangeCells[1] = nil
	exchangeCells[2] = nil
end

function ChessboardLayer:exchangeCellIndex(twoCells)
	local firstCellRowIndex = twoCells[1]:getRowIndex()
	local firstCellColIndex = twoCells[1]:getColIndex()
	twoCells[1]:setRowIndex(twoCells[2]:getRowIndex())
	twoCells[1]:setColIndex(twoCells[2]:getColIndex())
	twoCells[2]:setRowIndex(firstCellRowIndex)
	twoCells[2]:setColIndex(firstCellColIndex)
end

--计算可以消除的宝石个数，包括横向和纵向
function ChessboardLayer:calculateLinkNum(cell)
	local startRowIndex = cell:getRowIndex()
	local startColIndex = cell:getColIndex()
	local totalLandscapeChessCell = self:filterLandscapeCells(cell:getRowIndex())
	local totalPortraitChessCell = self:filterPortraitCells(cell:getColIndex())
	local landsLeftNum,landsLeftCellIndexAry = self:leftNum(startColIndex, cell:getType(), totalLandscapeChessCell)
	local landsRightNum,landsRightCellIndexAry = self:rightNum(startColIndex, cell:getType(), totalLandscapeChessCell)
	local portraitUpNum,portraitUpCellIndexAry = self:upNum(startRowIndex, cell:getType(), totalPortraitChessCell)
	local portraitDownNum,portraitDownCellIndexAry = self:downNum(startRowIndex, cell:getType(), totalPortraitChessCell)

	local landsNum = landsLeftNum + landsRightNum
	local portraitNum = portraitUpNum + portraitDownNum

	-- print("type:" .. cell:getType() .. "；横向个数：" .. landsNum .. "，纵向个数：" .. portraitNum)
	if landsNum > 2 and portraitNum > 2 then
		self:removeLandsCell(landsLeftCellIndexAry, landsRightCellIndexAry)
		self:removePortraitCell(portraitUpCellIndexAry, portraitDownCellIndexAry)
		print("横向有" .. landsNum .. "个可以消去;" .. "纵向有" .. portraitNum .. "个可以消去")
	elseif landsNum > 2 then
		self:removeLandsCell(landsLeftCellIndexAry, landsRightCellIndexAry)
		print("横向有" .. landsNum .. "个可以消去")
	elseif portraitNum > 2 then
		self:removePortraitCell(portraitUpCellIndexAry, portraitDownCellIndexAry)
		print("纵向有" .. portraitNum .. "个可以消去")
	else
		print("没有可消去的宝石")
	end
	print("=================================================")
end

--根据rowIndex和colIndex索引找出cellList中的这个格子,然后移除
function ChessboardLayer:removeLandsCell(landsLeftCellIndexAry, landsRightCellIndexAry)
	local landsCellIndexAry = tableUtil.combineTwoLabel(landsLeftCellIndexAry, landsRightCellIndexAry)
	for i,v1 in ipairs(landsCellIndexAry) do
		for i2,v2 in ipairs(cellList) do
			if v2:getRowIndex() == v1.rowIndex and v2:getColIndex() == v1.colIndex then
				self:disappearAnimation(cellList[i2],i2)
				break
			end
		end
	end
end

function ChessboardLayer:removePortraitCell(portraitUpCellIndexAry, portraitDownCellIndexAry)
	local portraitCellIndexAry = tableUtil.combineTwoLabel(portraitUpCellIndexAry, portraitDownCellIndexAry)
	for i,v1 in ipairs(portraitCellIndexAry) do
		for i2,v2 in ipairs(cellList) do
			if v2:getRowIndex() == v1.rowIndex and v2:getColIndex() == v1.colIndex then
				self:disappearAnimation(cellList[i2],i2)
				break
			end
		end
	end
end

function ChessboardLayer:leftNum(startColIndex, cellType, totalLandscapeChessCell)
	--假设在第7行 startRowIndex = 7
	local num = 0
	--记录可能被消去的格子在cellList中的索引
	local cellIndexAry = {}
	if startColIndex < 1 or startColIndex > COL_MAX  then
		return 0
	end

	for i = startColIndex,1,-1 do
		repeat
			if not totalLandscapeChessCell[i] then
				break
			end
			if totalLandscapeChessCell[i]:getType() == cellType then
				num = num + 1
				cellIndexAry[#cellIndexAry + 1] = {rowIndex = totalLandscapeChessCell[i]:getRowIndex(), colIndex = totalLandscapeChessCell[i]:getColIndex()}
			else
				return num,cellIndexAry
			end
		until true
	end
	return num,cellIndexAry
end

function ChessboardLayer:rightNum(startColIndex, cellType, totalLandscapeChessCell)
	local num = -1
	local cellIndexAry = {}
	if startColIndex < 1 or startColIndex > COL_MAX  then
		return 0
	end
	for i = startColIndex,COL_MAX,1 do
		repeat
			if not totalLandscapeChessCell[i] then
				break
			end
		
			if totalLandscapeChessCell[i]:getType() == cellType then
				num = num + 1
				if i > startColIndex then
					cellIndexAry[#cellIndexAry + 1] = {rowIndex = totalLandscapeChessCell[i]:getRowIndex(), colIndex = totalLandscapeChessCell[i]:getColIndex()}
				end
			else
				return num,cellIndexAry
			end
		until true
	end
	return num,cellIndexAry
end

function ChessboardLayer:upNum(startRowIndex, cellType, totalPortraitChessCell)
	local num = 0
	local cellIndexAry = {}
	if startRowIndex < 1 or startRowIndex > ROW_MAX  then
		return 0
	end
	for i = startRowIndex,1,-1 do
		repeat
			if not totalPortraitChessCell[i] then
				break
			end
		
			if totalPortraitChessCell[i]:getType() == cellType then
				num = num + 1
				cellIndexAry[#cellIndexAry + 1] = {rowIndex = totalPortraitChessCell[i]:getRowIndex(), colIndex = totalPortraitChessCell[i]:getColIndex()}
			else
				return num,cellIndexAry
			end
		until true
	end
	return num,cellIndexAry
end

function ChessboardLayer:downNum(startRowIndex, cellType, totalPortraitChessCell)
	local num = -1
	local cellIndexAry = {}
	if startRowIndex < 1 or startRowIndex > ROW_MAX  then
		return 0
	end
	for i = startRowIndex,ROW_MAX,1 do
		repeat
			if not totalPortraitChessCell[i] then
				break
			end
		
			if totalPortraitChessCell[i]:getType() == cellType then
				num = num + 1
				if i > startRowIndex then
					cellIndexAry[#cellIndexAry + 1] = {rowIndex = totalPortraitChessCell[i]:getRowIndex(), colIndex = totalPortraitChessCell[i]:getColIndex()}
				end
			else
				return num,cellIndexAry
			end
		until true
	end
	return num,cellIndexAry
end

function ChessboardLayer:filterLandscapeCells(startRowIndex)
	local cells = {}
	for i=1,#cellList do
		if cellList[i]:getRowIndex() == startRowIndex then
			cells[#cells + 1] = cellList[i]
			if #cells == COL_MAX   then
				return cells
			end
		end
	end
	return cells
end

function ChessboardLayer:filterPortraitCells(startColIndex)
	local cells = {}
	for i=1,#cellList do
		if cellList[i]:getColIndex() == startColIndex then
			cells[#cells + 1] = cellList[i]
			if #cells == ROW_MAX   then
				return cells
			end
		end
	end
	return cells
end

function ChessboardLayer:disappearAnimation(cell,index)
	local sequence = transition.sequence({
    CCScaleTo:create(0.2, 0.5),
    CCRotateBy:create(0.2, 360),
    CCScaleTo:create(0.1, 1),})

	cell:runAction(sequence)
	self:performWithDelay(function()
    -- 等待 1.5 秒后执行代码
    cellLayer:removeChild(cell,false)
end, 0.5)
	table.remove(cellList,index)
end

-- function ChessboardLayer:onEnter()
--     if device.platform == "android" then
--         -- avoid unmeant back
--         self:performWithDelay(function()
--             -- keypad layer, for android
--             local layer = display.newLayer()
--             layer:addKeypadEventListener(function(event)
--                 if event == "back" then app.exit() end
--             end)
--             self:addChild(layer)

--             layer:setKeypadEnabled(true)
--         end, 0.5)
--     end
-- end

return ChessboardLayer