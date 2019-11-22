module MissileEmitter
  class BattleField < BasicObject

    def initialize(context, *extras, callable)
      @context, @extras, @handler = context, extras, callable
    end

    def method_missing(*args, &block)
      @handler.call @context, *@extras, *args, &block
    end

    alias_method :emit!, :instance_eval

  end
end