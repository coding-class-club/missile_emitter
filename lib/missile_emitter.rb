require "missile_emitter/version"
require "pry" rescue nil

module MissileEmitter

  class Error < StandardError; end

  @mapping = {}

  class << self
    attr_accessor :mapping
  end

  def self.extended(klass)
    raise Error.new("不能扩展匿名模块") unless klass.name

    ::Kernel.define_method klass.name do |&block|
      klass
    end
  end

  module ::Kernel
    def MissileEmitter(λ)
      raise TypeError unless (λ.lambda? rescue false)

      context = λ.binding.eval 'self'

      MissileEmitter.mapping[context] = λ if context.instance_of?(Module)

      MissileEmitter
    end
  end

end
