module MissileEmitter
  RSpec.describe BattleField do

    it "继承自 BasicObject 而非 Object" do
      expect(BattleField).to be < BasicObject
      expect(BattleField).to_not be < Object
    end

    it "实例化时接收并保存可调用对象（Callable）" do
      callable = -> {}
      instance = BattleField.new callable

      expect(instance.instance_eval("@handler")).to eq callable
    end

  end
end