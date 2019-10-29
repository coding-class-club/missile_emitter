require "missile_emitter/version"
require "pry" rescue nil

module MissileEmitter
  class Error < StandardError; end

  module ::Kernel
    def MissileEmitter(λ)
      raise TypeError unless (λ.lambda? rescue false)
    end
  end
end
