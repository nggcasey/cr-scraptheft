require 'server.bridge'
require 'server.rep'
require 'server.loot'
require 'server.world'
require 'server.theft'
if require('shared.utils').config.EnableBuyers then require 'server.market' end

lib.print.info(('cr-thief loaded (framework: %s)'):format(require('server.bridge').framework))
