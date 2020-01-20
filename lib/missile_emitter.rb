require "active_support/core_ext/string"
require "missile_emitter/version"
require "missile_emitter/battle_field"

begin 
  require "pry" 
rescue LoadError
end

module MissileEmitter

  class Error < StandardError; end

  @mapping = {}

  class << self
    attr_accessor :mapping

    def exec(namespace, &block)
      raise Error, '需要提供代码块' unless block

      context = block.binding.receiver

      raise Error, '只能再具名模块中调用' unless context.instance_of?(Module) && context.name

      mimic_method context, namespace: namespace

      mapping[context] = block
    end

    private

    def mimic_method(context, namespace: true)
      path = context.name

      ns = path.deconstantize
      name = path.demodulize

      # 处理嵌套模块
      container = !ns.empty? && namespace ? ns.constantize : Kernel
      action = container == Kernel ? 'define_method' : 'define_singleton_method'

      container.send action, name do |*args, &missile|
        klass = missile.binding.receiver
        battle_field = BattleField.new klass, *args, MissileEmitter.mapping[context]
        battle_field.emit!(&missile)

        context
      end
    end

  end

end

module Kernel
  def MissileEmitter(namespace: true, &block)
    MissileEmitter.exec namespace, &block
  end
end
