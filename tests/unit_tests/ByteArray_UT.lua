--[[
    WireBait for wirebait is a lua package to help write Wireshark
    Dissectors in lua
    [Wirebait on Github](https://github.com/MarkoPaul0/WireBait)
    Copyright (C) 2015-2017 Markus Leballeux

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local is_standalone_test = not tester; --if only this file is being tested (not part of run all)
local tester = tester or require("tests.tester")

local ByteArray = require("wirebaitlib.primitives.ByteArray")

--[[ All variables here need to be kept local, however the unit test framework will run
each individual test function added with UnitTestsSet:addTest() in its own environment,
therefore forgetting the local keyword will not have a negative impact.
]]--
--Creating unit tests
local unit_tests = tester.newUnitTestsSet("ByteArray Unit Tests");

unit_tests:addTest("Testing ByteArray construction", function()
    local b = ByteArray.new("A0102FB1");
    tester.assert(b.m_data_as_hex_str, "A0102FB1", "Wrong underlying data");
    tester.assert(b:len(), 4, "Wrong size after construction")
end);

unit_tests:addTest("Testing ByteArray construction with empty string", function()
    local b = ByteArray.new("");
    tester.assert(b.m_data_as_hex_str, "", "Wrong underlying data");
    tester.assert(b:len(), 0, "Wrong size after construction")
end);

unit_tests:addTest("Testing ByteArray buffer:len()", function()
    tester.assert(ByteArray.new("4845"):len(), 2, "Wrong byte length");
end)

unit_tests:addTest("Testing ByteArray:get_index()", function()
    local b = ByteArray.new("0400FFAA");
    tester.assert(b:get_index(0), 4, "Wrong value at index 0");
    tester.assert(b:get_index(1), 0, "Wrong value at index 0");
    tester.assert(b:get_index(2), 255, "Wrong value at index 0");
    tester.assert(b:get_index(3), 170, "Wrong value at index 0");
end);

unit_tests:addTest("Testing ByteArray:__eq()", function()
    local b1 = ByteArray.new("0400FFAA");
    local b2 = ByteArray.new("0400FFAA");
    local b3 = ByteArray.new("0400FFAB");
    tester.assert(b1 == b2, true, "b1 and b2 should be equal");
    tester.assert(b2 == b3, false, "b2 and b3 should NOT be equal");
    tester.assert(b1 == b3, false, "b1 and b3 should NOT be equal");
end);

unit_tests:addTest("Testing ByteArray:__concat()", function()
    local b1 = ByteArray.new("0102");
    local b2 = ByteArray.new("0304");
    local b3 = b1 .. b2;
    tester.assert(b3:len(), 4, "Concatenated ByteArray is of unexpected size");
    tester.assert(b3.m_data_as_hex_str, "01020304", "Concatenated ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:prepend()", function()
    local b1 = ByteArray.new("0102");
    local b2 = ByteArray.new("0304");
    b1:prepend(b2);
    tester.assert(b1:len(), 4, "ByteArray is of unexpected size");
    tester.assert(b1.m_data_as_hex_str, "03040102", "ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:append()", function()
    local b1 = ByteArray.new("0102");
    local b2 = ByteArray.new("0304");
    b1:append(b2);
    tester.assert(b1:len(), 4, "ByteArray is of unexpected size");
    tester.assert(b1.m_data_as_hex_str, "01020304", "ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:set_size() (reducing size)", function()
    local b1 = ByteArray.new("010203040506");
    b1:set_size(3)
    tester.assert(b1:len(), 3, "ByteArray is of unexpected size");
    tester.assert(b1.m_data_as_hex_str, "010203", "ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:set_size() (increasing size)", function()
    local b1 = ByteArray.new("0102");
    b1:set_size(4)
    tester.assert(b1:len(), 4, "ByteArray is of unexpected size");
    tester.assert(b1.m_data_as_hex_str, "01020000", "ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:set_size() (size unchanged)", function()
    local b1 = ByteArray.new("0102");
    b1:set_size(2)
    tester.assert(b1:len(), 2, "ByteArray is of unexpected size");
    tester.assert(b1.m_data_as_hex_str, "0102", "ByteArray does not contain expected data");
end);

unit_tests:addTest("Testing ByteArray:__tostring()", function()
    local b = ByteArray.new("A0102FB1");
    tester.assert(tostring(b), "A0102FB1", "__tostring() produced unexpected data");
end);

unit_tests:addTest("Testing ByteArray:toHex()", function()
    local b = ByteArray.new("A0102FB1");
    tester.assert(b:toHex(), "A0102FB1", "__tostring() produced unexpected data");
end);

unit_tests:addTest("Testing ByteArray:subset()", function()
    local b = ByteArray.new("A0102FB1");
    local b2 = b:subset(1,2);
    local b3 = b:subset(0,3);
    local b4 = b:subset(2,1);
    tester.assert(b2.m_data_as_hex_str, "102F", "subset() produced unexpected data");
    tester.assert(b3.m_data_as_hex_str, "A0102F", "subset() produced unexpected data");
    tester.assert(b4.m_data_as_hex_str, "2F", "subset() produced unexpected data");
end);

unit_tests:addTest("Testing ByteArray:tvb()", function()
    local b = ByteArray.new("A0102FB1");
    local tvb = b:tvb();
    tester.assert(tvb.m_byte_array, b, "Produced tvb should have byte array as underlying data");
    tester.assert(tvb.m_byte_array.m_data_as_hex_str, "A0102FB1", "Produced tvb should have byte array as underlying data");
end);

unit_tests:addTest("Testing ByteArray:swapByteOrder() (2 bytes)", function()
    local b  = ByteArray.new("0102")
    local sb = ByteArray.new("0201");
    tester.assert(b:swapByteOrder(), sb, "ByteArray:swapByteOrder() failed");
end);

unit_tests:addTest("Testing ByteArray:swapByteOrder() (4 bytes)", function()
    local b  = ByteArray.new("01020304")
    local sb = ByteArray.new("04030201");
    tester.assert(b:swapByteOrder(), sb, "ByteArray:swapByteOrder() failed");
end);

unit_tests:addTest("Testing ByteArray:swapByteOrder() (8 bytes)", function()
    local b  = ByteArray.new("0102030405060708")
    local sb = ByteArray.new("0807060504030201");
    tester.assert(b:swapByteOrder(), sb, "ByteArray:swapByteOrder() failed");
end);

if is_standalone_test then
    tester.test(unit_tests);
    tester.printReport();
else
    return unit_tests
end
