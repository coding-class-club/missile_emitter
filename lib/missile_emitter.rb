require "missile_emitter/version"
require "missile_emitter/battle_field"

require "pry" rescue nil

module MissileEmitter

  class Error < StandardError; end

  @mapping = {}

  class << self
    attr_accessor :mapping

    def exec(&block)
      raise Error.new("需要提供代码块") unless block_given?

      context = block.binding.eval 'self'

      raise Error.new("只能再具名模块中调用") unless context.instance_of?(Module) && context.name

      mimic_method context

      mapping[context] = block
    end

    private

    def mimic_method(context)
      # TODO：处理多层命名空间的情况
      Kernel.define_method context.name do |&missile|
        klass = missile.binding.eval 'self'
        battle_field = BattleField.new klass, MissileEmitter.mapping[context]
        battle_field.emit! &missile

        context
      end
    end
  end

end

module Kernel
  def MissileEmitter(&block)
    MissileEmitter.exec &block
  end
end
