local argtype = {none=true,maybe=0,one=1,any=-1,many=2,all=3}

local function getopt(optstring,args,longopts,skipunknown)
  if not args or #args == 0 then return {},nil end
  local opts,k,v,erropts = {},nil,nil,{}
  for k,v in optstring:gmatch('(%w)([.:+*~]?)') do
    if not v or #v == 0 then
      opts[k] = true
    elseif v == '.' then
      opts[k] = 0
    elseif v == ':' then
      opts[k] = 1
    elseif v == '+' then
      opts[k] = 2
    elseif v == '*' then
      opts[k] = -1
    elseif v == '~' then
      opts[k] = 3
    end
  end
  if type(longopts) ~= 'table' then longopts={} end
  local resolveopt = function(o,l,s)
      if #o < 1 then return nil end
      while type(l[o]) == 'string' do o=l[o] end
      if s[o] then return o,s[o] end
      return o,l[o]
    end
  local result,lastopt,opttype,unparsed={},nil,nil,nil
  local consumeopt=nil
  for k,v in ipairs(args) do
      if consumeopt then
        result[consumeopt][#result[consumeopt]+1] = v
        opttype = nil
      elseif opttype and opttype > 0 then
        if opttype == 1 then
          result[lastopt] = v
        else
          if not result[lastopt] then result[lastopt] = {} end
          result[lastopt][#result[lastopt]+1] = v
        end
        opttype = nil
      elseif v == "--" then -- abort parsing
        lastopt,opttype = nil,nil
        unparsed = k+1
        break
      elseif v:sub(1,2) == '--' then -- longopts
        lastopt,opttype = resolveopt(v:sub(3),longopts,opts)
        if opttype == nil then 
          if not skipunknown then return false, "Unknown option '"..v.."'", v:sub(3) end
          opttype=nil
          erropts[#erropts+1] = v:sub(3)
        elseif opttype == true then
          result[lastopt] = true
          opttype = nil
        elseif opttype == 0 then
          if not result[lastopt] then result[lastopt] = true end
        elseif opttype == 1 then
          result[lastopt] = false
        else
          if not result[lastopt] then result[lastopt] = {} end
          if opttype == 3 then consumeopt=lastopt end
        end
      elseif v:sub(1,1) == '-' then -- short opts
        lastopt,opttype = nil,nil
        local i,j
        for i=2,#v do
          j=i+1
          lastopt = v:sub(i,i)
          opttype = opts[lastopt]
          if not opttype then
            if not skipunknown then return false, "Unknown option '"..lastopt.."'", lastopt end
            erropts[#erropts+1] = lastopt
          elseif opttype == true then
            result[lastopt] = true
            opttype = nil
          elseif opttype == 0 then
            if not result[lastopt] then result[lastopt] = true end
          elseif opttype <= -1 or opttype >= 2 then
            if not result[lastopt] then result[lastopt] = {} end
            if opttype == 3 then consumeopt=lastopt end
            if opttype > 0 then break end
          elseif opttype == 1 then
            result[lastopt] = result[lastopt] or false
            if opttype > 0 then break end
          end
        end
        i=v:sub(j)
        if i and #i>0 then 
          if opttype == 1 then
            result[lastopt] = i
          elseif opttype then
            result[lastopt][#result[lastopt]+1] = i
          end
          opttype = nil
        end
      elseif opttype then
        if opttype == 1 or opttype == 0 then
          result[lastopt] = opt
        else
          result[lastopt][#result[lastopt]+1] = opt
        end
        opttype = nil
      else
        unparsed = k
        break
      end
  end
  if opttype then return false, "Missing value for '"..lastopt.."'", lastopt end
  return result, (unparsed and unparsed <= #args and unparsed), skipunknown and erropts
end
--[[
opts, nonopts, unopts = getopt("asd~", arg, {testme=argtype.one},true)
if not opts then print(nonopts); return end
for k,v in pairs(opts) do
  if type(v) == 'table' then
    print(k, "[", table.concat(v, ', '), ']')
  else
    print(k,v)
  end
end
nonopts = nonopts or #arg+1
for i=nonopts,#arg do
  print("#", arg[i])
end
for _,v in ipairs(unopts or {}) do
  print("Unknown: ", v)
end
]]
local M={}
M.getopt=getopt
M.argtype=argtype
return M
   
    
--: vim: set ts=2 sw=2 tw=0 et :--
