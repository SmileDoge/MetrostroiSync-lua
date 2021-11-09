local string_char = string.char
local string_byte_raw = string.byte
local table_insert = table.insert

local bit_band   = bit.band
local bit_bor    = bit.bor
local bit_lshift = bit.lshift
local bit_rshift = bit.rshift

local math_frexp = math.frexp
local math_ldexp = math.ldexp
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_huge = math.huge

string_byte = function(a,b,c)
    if a == nil then return 0 else return string_byte_raw(a,b,c) end
end

local Buffer = {}
local Buffer_meta = {
    __index = Buffer,
    __tostring = function (self)
        return table.concat(self.data, "", 1, self.size)
    end
}

local buffer_data_size = 2048+1

local function createTable(size)
    local tbl = {}
    for i = 1, size do
        tbl[i] = "\0"
    end
    return tbl
end

function Metrostroi.SyncSystem.Buffer()
    local ret = setmetatable({
        offset = 1,
        data = createTable(buffer_data_size),
        size = 0,
    }, Buffer_meta)

    return ret
end

local function PackIEEE754Float(number)
	if number == 0 then
		return 0x00, 0x00, 0x00, 0x00
	elseif number == math_huge then
		return 0x00, 0x00, 0x80, 0x7F
	elseif number == -math_huge then
		return 0x00, 0x00, 0x80, 0xFF
	elseif number ~= number then
		return 0x00, 0x00, 0xC0, 0xFF
	else
		local sign = 0x00
		if number < 0 then
			sign = 0x80
			number = -number
		end
		local mantissa, exponent = math_frexp(number)
		exponent = exponent + 0x7F
		if exponent <= 0 then
			mantissa = math_ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0xFF then
				return 0x00, 0x00, 0x80, sign + 0x7F
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math_floor(math_ldexp(mantissa, 23) + 0.5)
		return mantissa % 0x100,
				bit_rshift(mantissa, 8) % 0x100,
				(exponent % 2) * 0x80 + bit_rshift(mantissa, 16),
				sign + bit_rshift(exponent, 1)
	end
end
local function UnpackIEEE754Float(b4, b3, b2, b1)
	local exponent = (b1 % 0x80) * 0x02 + bit_rshift(b2, 7)
	local mantissa = math_ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
	if exponent == 0xFF then
		if mantissa > 0 then
			return 0 / 0
		else
			if b1 >= 0x80 then
				return -math_huge
			else
				return math_huge
			end
		end
	elseif exponent > 0 then
		mantissa = mantissa + 1
	else
		exponent = exponent + 1
	end
	if b1 >= 0x80 then
		mantissa = -mantissa
	end
	return math_ldexp(mantissa, exponent - 0x7F)
end
local function PackIEEE754Double(number)
	if number == 0 then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	elseif number == math_huge then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F
	elseif number == -math_huge then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF
	elseif number ~= number then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0xFF
	else
		local sign = 0x00
		if number < 0 then
			sign = 0x80
			number = -number
		end
		local mantissa, exponent = math_frexp(number)
		exponent = exponent + 0x3FF
		if exponent <= 0 then
			mantissa = math_ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0x7FF then
				return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, sign + 0x7F
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math_floor(math_ldexp(mantissa, 52) + 0.5)
		return mantissa % 0x100,
				math_floor(mantissa / 0x100) % 0x100,  --can only rshift up to 32 bit numbers. mantissa is too big
				math_floor(mantissa / 0x10000) % 0x100,
				math_floor(mantissa / 0x1000000) % 0x100,
				math_floor(mantissa / 0x100000000) % 0x100,
				math_floor(mantissa / 0x10000000000) % 0x100,
				(exponent % 0x10) * 0x10 + math_floor(mantissa / 0x1000000000000),
				sign + bit_rshift(exponent, 4)
	end
end
local function UnpackIEEE754Double(b8, b7, b6, b5, b4, b3, b2, b1)
	local exponent = (b1 % 0x80) * 0x10 + bit_rshift(b2, 4)
	local mantissa = math_ldexp(((((((b2 % 0x10) * 0x100 + b3) * 0x100 + b4) * 0x100 + b5) * 0x100 + b6) * 0x100 + b7) * 0x100 + b8, -52)
	if exponent == 0x7FF then
		if mantissa > 0 then
			return 0 / 0
		else
			if b1 >= 0x80 then
				return -math_huge
			else
				return math_huge
			end
		end
	elseif exponent > 0 then
		mantissa = mantissa + 1
	else
		exponent = exponent + 1
	end
	if b1 >= 0x80 then
		mantissa = -mantissa
	end
	return math_ldexp(mantissa, exponent - 0x3FF)
end

function Buffer:init(data)
    if data ~= nil then
        if type(data) == "string" then
            self.data = string.Split(data, "")
        else
            self.data = data
        end

        self.size = #self.data
    end
end

function Buffer:seek(pos)
    self.offset = pos
end

function Buffer:writeInt8(i8)
    if self.offset+1 > buffer_data_size then error("Data will be out of bounds") end 
    local offset = self.offset

    self.data[offset] = string_char(bit_band(i8, 0xff))

    self.offset = offset + 1
    self.size = self.size + 1
end

function Buffer:writeInt16(i16)
    if self.offset+2 > buffer_data_size then error("Data will be out of bounds") end 
    local offset = self.offset

    self.data[offset  ] = string_char(bit_band(i16, 0xff))
    self.data[offset+1] = string_char(bit_band(bit_rshift(i16, 8), 0xff))

    self.offset = offset + 2
    self.size = self.size + 2
end

function Buffer:writeInt32(i32)
    if self.offset+4 > buffer_data_size then error("Data will be out of bounds") end 
    local offset = self.offset

    self.data[offset  ] = string_char(bit_band(i32, 0xff))
    self.data[offset+1] = string_char(bit_band(bit_rshift(i32, 8), 0xff))
    self.data[offset+2] = string_char(bit_band(bit_rshift(i32, 16), 0xff))
    self.data[offset+3] = string_char(bit_band(bit_rshift(i32, 24), 0xff))

    self.offset = offset + 4
    self.size = self.size + 4
end

function Buffer:writeFloat(f32)
    if self.offset+4 > buffer_data_size then error("Data will be out of bounds") end
    
    local offset = self.offset
    local a,b,c,d = PackIEEE754Float(f32)
    
    self.data[offset  ] = string_char(a)
    self.data[offset+1] = string_char(b)
    self.data[offset+2] = string_char(c)
    self.data[offset+3] = string_char(d)

    self.offset = offset + 4
    self.size = self.size + 4
end

function Buffer:writeDouble(d64)
    if self.offset+8 > buffer_data_size then error("Data will be out of bounds") end
    
    local offset = self.offset
    local a,b,c,d,e,f,g,h = PackIEEE754Double(d64)
    
    self.data[offset  ] = string_char(a)
    self.data[offset+1] = string_char(b)
    self.data[offset+2] = string_char(c)
    self.data[offset+3] = string_char(d)
    self.data[offset+4] = string_char(e)
    self.data[offset+5] = string_char(f)
    self.data[offset+6] = string_char(g)
    self.data[offset+7] = string_char(h)

    self.offset = offset + 8
    self.size = self.size + 8
end

function Buffer:writeBytes(data)
    if self.offset+(#data) > buffer_data_size then error("Data will be out of bounds") end 
    local offset = self.offset

    for i = 1, #data do
        if type(data[i]) == "number" then data[i] = string_char(data[i]) end
        self.data[i-1 + offset] = data[i]
    end

    self.offset = offset + #data
    self.size = self.size + #data
end

function Buffer:writeString(data)
    self:writeInt32(#data)
    self:writeBytes(data)
end

function Buffer:readInt8()
    local offset = self.offset
    if offset + 1 > buffer_data_size then error("Data will be out of bounds") end 

    local a = string_byte(self.data[offset  ])

    self.offset = offset + 1

    return a
end

function Buffer:readInt16()
    local offset = self.offset
    if offset + 2 > buffer_data_size then error("Data will be out of bounds") end 

    local a = string_byte(self.data[offset  ])
    local b = string_byte(self.data[offset+1])

    self.offset = offset + 2

    return a + bit.lshift(b, 8)
end

function Buffer:readInt32()
    local offset = self.offset
    if offset + 4 > buffer_data_size then error("Data will be out of bounds") end 

    local a = string_byte(self.data[offset  ])
    local b = string_byte(self.data[offset+1])
    local c = string_byte(self.data[offset+2])
    local d = string_byte(self.data[offset+3])

    self.offset = offset + 4

    return a + bit.lshift(b, 8) + bit.lshift(c, 16) + bit.lshift(d, 24)
end

function Buffer:readFloat()
    local offset = self.offset
    if offset + 4 > buffer_data_size then error("Data will be out of bounds") end 

    local a = string_byte(self.data[offset  ])
    local b = string_byte(self.data[offset+1])
    local c = string_byte(self.data[offset+2])
    local d = string_byte(self.data[offset+3])

    self.offset = offset + 4

    return UnpackIEEE754Float(a, b, c, d)
end

function Buffer:readDouble()

    local offset = self.offset
    if offset + 8 > buffer_data_size then error("Data will be out of bounds") end 

    local a = string_byte(self.data[offset  ])
    local b = string_byte(self.data[offset+1])
    local c = string_byte(self.data[offset+2])
    local d = string_byte(self.data[offset+3])
    local e = string_byte(self.data[offset+4])
    local f = string_byte(self.data[offset+5])
    local g = string_byte(self.data[offset+6])
    local h = string_byte(self.data[offset+7])

    self.offset = offset + 8

    return UnpackIEEE754Double(a, b, c, d, e, f, g, h)
end

function Buffer:readBytes(length)
    local offset = self.offset
    if offset + length > buffer_data_size then error("Data will be out of bounds") end 

    local temp = {}

    for i = 1, length do
        temp[i] = string.byte(self.data[i-1 + offset])
    end

    self.offset = offset + length

    return temp
end

function Buffer:readStringRaw(length)
    local temp = {}

    for k,v in pairs(self:readBytes(length)) do
        temp[k] = string.char(v)
    end

    return table.concat(temp)
end

function Buffer:readString()
    return self:readStringRaw(self:readInt32())
end

function Buffer:getString()
    return table.concat(self.data, "", 1, self.size)
end