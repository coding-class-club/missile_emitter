module MissileEmitter
  RSpec.describe BattleField do
    it "继承自 BasicObject 而非 Object" do
      expect(BattleField).to be < BasicObject
      expect(BattleField).to_not be < Object
    end
  end
end