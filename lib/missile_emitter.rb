require "missile_emitter/version"
require "missile_emitter/battle_field"
require "pry" rescue nil

module MissileEmitter

  class Error < StandardError; end

  @mapping = {}

  class << self
    attr_accessor :mapping
  end

  module ::Kernel
    def MissileEmitter(&block)
      raise LocalJumpError.new('no block given') unless block_given?

      context = block.binding.eval 'self'

      raise Error.new("不能扩展匿名模块") unless context.name

      ::Kernel.define_method context.name do |&missile|
        klass = missile.binding.eval 'self'
        battle_field = BattleField.new klass, MissileEmitter.mapping[context]
        battle_field.emit! &missile

        context
      end

      MissileEmitter.mapping[context] = block if context.instance_of?(Module)
    end
  end

end
