local string=require('string')
local CSI = string.char(27,91)
local CSISGR = {
--[[ reset ]]
    reset=0,
--[[ font weight ]]
    bright=1, bold=1, faint=2, 
--[[ font style ]]
    italic=3, underline=4, 
    blink=5, invert=7, conceal=8, crossed=9,
--[[ font family ]]
    primaryfont=10, font1=11, font2=12, font3=13, font4=14, font5=15, 
    font6=16, font7=17, font8=18, font9=19, 
--[[ revert font style ]]
    normal=22, nounderline=24, 
    noblink=25, noinvert=27, noconceal=28, nocrossed=29,
--[[ foreground color ]]
    black=30, red=31, green=32, yellow=33, blue=34, magenta=35, cyan=36,
    white=37, defaultfg=39,
--[[ background color ]]
    blackbg=40, redbg=41, greenbg=42, yellowbg=43, bluebg=44, magentabg=45,
    cyanbg=46, whitebg=47, defaultbg=49
}

function csi(s,t,...)
    t = type(t) == 'table' and t or {t,...}
    return CSI..table.concat(t,';')..s
end
function csisgr(s,tp)
    if tp and #tp>0 then return string.csi(tp,s) end
    local ct,c={}
    for c in string.gmatch(s,'([^;]+)') do ct[#ct+1] = CSISGR[c] end
    return csi('m',ct)
end

function csifmt(s)
    return string.gsub(s,'(&+)(%w?)(%b[])', function(esc, tp, val)
        if #esc % 2 == 0 then 
            return esc:sub(1,#esc/2) .. (tp or '') .. val
        elseif #esc == 1 then 
            return csisgr(val:sub(2,#val-1), tp)
        else
            return esc:sub(1,(#esc-1)/2) .. csisgr(val:sub(2,#val-1), tp)
        end
    end)
end

function stripcsi(s)
    return string.gsub(s,'(&+)(%w?)(%b[])', function(esc, tp, val)
        if #esc % 2 == 0 then 
            return esc:sub(1,#esc/2) .. (tp or '') .. val
        elseif #esc == 1 then 
            return ''
        else
            return esc:sub(1,(#esc-1)/2)
        end
    end)
end
function formatc(s,...)
    return csifmt(s):format(...)
end


local M = {
CSI=CSI,
CSISGR=CSISGR,
csi=csi,
csisgr=csisgr,
csifmt=csifmt,
stripcsi=stripcsi,
formatc=formatc
}
M.__index=M
setmetatable(M,M)

string.csisgr=csisgr
string.csifmt=csifmt
string.stripcsi=stripcsi
string.formatc=formatc

return M

--[[
print(("&m[38;5;100]hio&[reset]"):colfmt())
print(("&m[38;2;200;200;50]hio&[reset]"):colfmt())
print(("&[faint;bgblue;red]hio&[reset]"):colfmt())
print(("&[bgblue;faint;red]hio&[reset]"):colfmt())
print(("&&-&&[green]&[bright;bgblue;faint;red]hio&[reset]"):colfmt())
]]
