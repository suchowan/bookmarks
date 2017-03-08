# -*- coding: utf-8 -*-
=begin
  This script was written by Takashi SUGA on February 2017

  You may use and/or modify this file according to the license described in the MIT LICENSE.txt file https://raw.githubusercontent.com/suchowan/watson-api-client/master/LICENSE.
=end

require 'when_exe'
require 'when_exe/core/extension'

include When

Epoch  = when?('1600-12-30T08:59:59.844+09:00:00')

def serial2date(serial)
  seed = 0
  8.times do |i|
    seed = seed * 256 + serial[(-4-2*i)..(-3-2*i)].to_i(16)
  end
  Epoch + When::PT1S * (seed / 10_000_000.0)
end

