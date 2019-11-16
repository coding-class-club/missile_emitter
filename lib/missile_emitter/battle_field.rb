module MissileEmitter
  class BattleField < BasicObject

    def initialize(context, callable)
      @context, @handler = context, callable
    end

    def method_missing(*args, &block)
      @handler.call @context, *args, &block
    end

    alias_method :emit!, :instance_eval

  end
end