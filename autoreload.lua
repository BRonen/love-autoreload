local ffi = require('ffi') --need luajit to use
local lfs = require('lfs') --install luafilesystem

local Files = {} --files on current file
--[[ TODO: do a recursive function that insert files in sub-folders too ]]
local currentLove

local function restartLove()
  io.close(currentLove)
  currentLove = assert(io.popen('love .', 'r')) --run a new instance of love
end

local function updateFiles()
  local file = assert(io.popen('ls', 'r')) --run ls
  local output = file:read('*all')
  file:close()

  for k, v in string.gmatch(output, "(%a+)%p([l][u][a])") do --filter .lua files
    local err
    Files[k..".lua"], err = lfs.attributes(k..".lua")
    assert(err == nil)
  end
end

local function main()
  for path, data in pairs(Files) do
    local modification = data.modification
    local access = data.access
    local change = data.change
    local err

    data, err = lfs.attributes(path)

    if
      modification ~= data.modification or
      access ~= data.access or
      change ~= data.change
    then
      print('file modified: '..path)
      restartLove()
      Files[path] = data
    end
  end
end

ffi.cdef("unsigned int sleep(unsigned int seconds);") --use the C function sleep

currentLove = assert(io.popen('love .', 'r')) --run a new instance of love

updateFiles()
while true do
  main()
  ffi.C.sleep(2) --you can use io.popen('sleep 2', 'r') but cant stop with Ctrl+C to stop
end
