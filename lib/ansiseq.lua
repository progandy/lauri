local CSI = string.char(27,91)
local CSISGR = {reset=0,bright=1,bold=1,faint=2,italic=3,underline=4,blink=5,invert=7,conceal=8,crossed=9,primaryfont=10,font1=11,font2=12,font3=13,font4=14,font5=15,font6=16,font7=17,font8=18,font9=19,normal=22,nounderline=24,noblink=25,noinvert=27,noconceal=28,nocrossed=29,black=30,red=31,green=32,yellow=33,blue=34,magenta=35,cyan=36,white=37,defaultcolor=39,bgblack=40,bgred=41,bggreen=42,bgyellow=43,bgblue=44,bgmagenta=45,bgcyan=46,bgwhite=47,bgdefaultcolor=49}

function string:csi(t,...)
    t = type(t) == 'table' and t or {t,...}
    return CSI..table.concat(t,';')..self
end
function string:csisgr(tp)
    if tp and #tp>0 then return tp:csi(self) end
    local ct,c={}
    for c in self:gmatch('([^;]+)') do ct[#ct+1] = CSISGR[c] end
    return string.csi('m',ct)
end

function string:csifmt()
    return self:gsub('(&+)(%w?)(%b[])', function(esc, tp, val)
        if #esc % 2 == 0 then 
            return esc:sub(1,#esc/2) .. (tp or '') .. val
        elseif #esc == 1 then 
            return val:sub(2,#val-1):csisgr(tp)
        else
            return esc:sub(1,(#esc-1)/2) .. val:sub(2,#val-1):csisgr(tp)
        end
    end)
end

function string:stripcsi()
    return self:gsub('(&+)(%w?)(%b[])', function(esc, tp, val)
        if #esc % 2 == 0 then 
            return esc:sub(1,#esc/2) .. (tp or '') .. val
        elseif #esc == 1 then 
            return ''
        else
            return esc:sub(1,(#esc-1)/2)
        end
    end)
end
function string:formatc(...)
    return self:csifmt():format(...)
end

return {CSI=CSI,CSISGR=CSISGR}

--[[
print(("&m[38;5;100]hio&[reset]"):colfmt())
print(("&m[38;2;200;200;50]hio&[reset]"):colfmt())
print(("&[faint;bgblue;red]hio&[reset]"):colfmt())
print(("&[bgblue;faint;red]hio&[reset]"):colfmt())
print(("&&-&&[green]&[bright;bgblue;faint;red]hio&[reset]"):colfmt())
]]
