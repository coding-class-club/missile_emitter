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

    def exec(&block)
      raise Error.new("需要提供代码块") unless block_given?

      context = block.binding.eval 'self'

      raise Error.new("只能再具名模块中调用") unless context.instance_of?(Module) && context.name

      mimic_method context

      mapping[context] = block
    end

    private

    def mimic_method(context)
      path = context.name

      ns = deconstantize path
      name = demodulize path

      # 处理嵌套模块
      namespace = ns.empty? ? Kernel : constantize(ns)
      action = namespace == Kernel ? 'define_method' : 'define_singleton_method'

      namespace.send action, name do |&missile|
        klass = missile.binding.eval 'self'
        battle_field = BattleField.new klass, MissileEmitter.mapping[context]
        battle_field.emit! &missile

        context
      end
    end

    def demodulize(path)
      path = path.to_s

      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    def deconstantize(path)
      path.to_s[0, path.rindex("::") || 0]
    end

    def constantize(camel_cased_word)
      names = camel_cased_word.split("::")

      Object.const_get(camel_cased_word) if names.empty?

      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          constant = constant.ancestors.inject(constant) do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          constant.const_get(name, false)
        end
      end
    end
  end

end

module Kernel
  def MissileEmitter(&block)
    MissileEmitter.exec &block
  end
end
