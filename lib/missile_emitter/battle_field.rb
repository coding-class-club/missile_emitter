module MissileEmitter
  class BattleField < BasicObject

    def initialize(callable)
      @handler = callable
    end

    def method_missing(msg, *args, &block)
      @handler.call msg, *args, &block
    end

  end
end