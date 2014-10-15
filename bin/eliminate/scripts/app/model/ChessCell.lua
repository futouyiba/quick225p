--
-- Author: hanxu
-- Date: 2014-03-07 14:33:53
--

local cellPic
local cellContainer

local ChessCell = class("ChessCell", function(  )
	return display.newNode()
end)

function ChessCell:ctor(cellContainer, typeInt, rowIndex, colIndex)
	cellContainer = cellContainer
	self.typeInt = typeInt
	self.rowIndex = rowIndex
	self.colIndex = colIndex
	cellPic = display.newSprite(typeInt .. ".png"):addTo(self)
	self:setContentSize(CCSize(64, 64))
end

function ChessCell:drawbackground()
	local shap = display.newRect(65,65)
	shap:setFill(true)
	shap:setLineColor(ccc4f(0, 1, 1, 1))
	self:addChild(shap)
end

function ChessCell:getType( )
	return self.typeInt
end

function ChessCell:setRowIndex(rowIndex)
	self.rowIndex = rowIndex
end

function ChessCell:setColIndex(colIndex)
	self.colIndex = colIndex
end

function ChessCell:getRowIndex(  )
	return self.rowIndex
end

function ChessCell:getColIndex(  )
	return self.colIndex
end

return ChessCell