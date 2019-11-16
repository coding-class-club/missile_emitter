module MissileEmitter
  class BattleField < BasicObject
    def initialize(callable)
      @handler = callable
    end
  end
end