--
-- Author: hanxu@apowo.com
-- Date: 2014-03-12 13:01:30
--

tableUtil = tableUtil or {}

function tableUtil.combineTwoLabel(t1,t2)
	--方法一 结果呢拼接下来顺序乱了
	-- local mt = {}
	-- mt.__add = function(a, b)
	-- 	local tbl = {}
	-- 	local ret = {}
	-- 	for k, v in pairs(a) do tbl[v] = true end
	-- 	for k, v in pairs(b) do tbl[v] = true end
	-- 	for k, v in pairs(tbl) do
	-- 		table.insert(ret, k)
	-- 	end
	-- 	return ret
	-- end
		 
	-- setmetatable(t1, mt)
	-- setmetatable(t2, mt)
	-- local t = t1 + t2 
	-- for k, v in pairs(t) do print(k, '', v) end
	-- return t

	--方法二 顺序正确
	-- local mt = {}
	-- mt.__add = function(a, b)
	-- 	local tbl = {}
	-- 	local ret = {}
	-- 	for k, v in pairs(a) do tbl[#tbl + 1] = v end
	-- 	for k, v in pairs(b) do tbl[#tbl + 1] = v end
	-- 	for k, v in pairs(tbl) do
	-- 		table.insert(ret, v)
	-- 	end
	-- 	return ret
	-- end
		 
	-- setmetatable(t1, mt)
	-- setmetatable(t2, mt)
	-- local t = t1 + t2 
	-- for k, v in pairs(t) do print(k, '', v) end
	-- return t
	
	--方法三 顺序正确 但是呢这个跟方法二比较那个更好呢
	local tbl = {}
	for k, v in pairs(t1) do tbl[#tbl + 1] = v end
	for k, v in pairs(t2) do tbl[#tbl + 1] = v end
	-- for k, v in pairs(tbl) do print(k, '', v) end
	return tbl
end

return tableUtil