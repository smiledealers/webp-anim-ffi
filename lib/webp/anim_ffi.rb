require 'ffi'

require_relative 'anim/version'

module WebP
  module Anim
    module C
      extend FFI::Library
      ffi_lib 'webpdemux'
    end
  end
end

require_relative 'anim/util'
require_relative 'anim/c'
require_relative 'anim/decoder'
require_relative 'anim/demuxer'
