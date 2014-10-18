local function dealias(opts, opt)
  if not opts or not opts[opt] then return nil end
  while opts[opt].alias do
    opt = opts[opt].alias
    if not opts[opt] then return nil end
  end
  return opt
end

--[[
  function optparse()
  *Parameters:
    - opts: table of options:
        { optname = {
            alias = nil -- treat this optname as an alias for the given name.
            maxval = 0, -- maximum amount of values (-1 for unlimited)
            minval = 0, -- minimum number of values required
            desc = "A description"
          }, ...
        }
    - args: list of given arguments
  *Return values:
    - table with { option = value }, or { option = {multiple, values}}
    - index of the first unparsed parameter
]]
local function optparse(opts, args)
  assert(args ~= nil)
  assert(opts ~= nil)
  
  local argname 
  local params = {}
  local valcounts = {}
  local argind = 1
  local val = args[1]
  local isargval=false
  local issplit=false
  while argind <= #args do
    if isargval then
      local p = opts[argname].maxval
      local c = valcounts[argname] or 0
      if p and p~=0 then
        if p == 1 then
          params[argname] = val
          valcounts[argname] = 1
        elseif p < 0 or c < p then
          valcounts[argname] = c + 1
          local t = params[argname]
          if c < 1 then t={} end
          t[c+1] = val
          params[argname] = t
        elseif issplit then
          error("Error: Parameter '"..argname.."' got too many values.")
        end
      elseif issplit then
        error("Error: Parameter '"..argname.."' does not accept a value.")
      else
        -- first non-parameter argument, abort
        break
      end
      -- we don't know what the next argument will be
      isargval = false
      issplit = false
      argname = nil
      -- switch to next argument
      argind = argind + 1
      val=args[argind]
    elseif val == "--" then 
      -- stop argument, abort
      argind=argind+1
      break
    elseif val:sub(1,2) == '--' then
      local name,value = val:match("^%-%-([^=]*)=?(.*)$")
      name=dealias(opts, name)
      if name then
        argname = name
        if not valcounts[argname] then params[argname] = true end
        if value and #value > 0 then
          issplit=true
          val=value
          isargval=true
        else
          -- switch to next argument
          argind = argind + 1
          val = args[argind]
        end
      else
        error("Error: Illegal option '" .. val:match("^[^=]*") .. "'")
        --if not argname then break end
        --isargval = true
      end
    elseif #val > 1 and val:sub(1,1) == '-' then
      local i=2
      local shopt
      while i <= #val do
        argname=dealias(opts, val:sub(i,i))
        if argname then
          if opts[argname].maxval and opts[argname].maxval ~= 0 then
            break
          elseif not params[argname] then
            params[shopt] = true
          end
        else
          error("Error: Illegal option '" .. val:sub(i,i).."'")
        end
        i = i + 1
      end
      -- if value is part of short option, use that
      if i < #val then
        issplit=true
        val=val:sub(i+1)
        isargval=true
      else
        -- switch to next argument
        argind = argind + 1
        val = args[argind]
      end
    elseif argname then
      isargval = true
    else
      -- first non-parameter argument, abort
      break
    end
  end
  for k,_ in pairs(opts) do
    k=dealias(opts,k)
    local v = opts[k]
    if v.minval and v.minval > 0 
      and params[k] and (not valcounts[k] or v.minval < valcounts[k])
    then 
        error("Error: Parameter '"..k.."' requires at least "
          ..v.minval.." value(s).") 
    end
  end
  return params, argind
end

--[[
opts, nonopts = optparse({v={maxval=-4}, ver={minval=1,maxval=-1}}, arg)
for k,v in pairs(opts) do
  if type(v) == 'table' then
    print(k, "[", table.concat(v, ', '), ']')
  else
    print(k,v)
  end
end
for i=nonopts,#arg do
  print("#", arg[i])
end
]]
local M={}
M.optparse=optparse
return M
   
    
--: vim: set ts=2 sw=2 tw=0 et :--
