module MissileEmitter
  RSpec.describe BattleField do

    it "继承自 BasicObject 而非 Object" do
      expect(BattleField.ancestors).to contain_exactly(BattleField, BasicObject)
    end

    it "实例化时接收并保存上下文（Context）和可调用对象（Callable）" do
      context = Class.new
      callable = -> {}

      instance = BattleField.new context, callable

      expect(instance.instance_eval("@context")).to eq context
      expect(instance.instance_eval("@handler")).to eq callable
    end

    it "使用 emit! 方法执行代码块，以便触发 method_missing 事件" do
      emit = BattleField.instance_method :emit!
      origin = BattleField.instance_method :instance_eval

      expect(emit).to eq origin 
    end

  end
end