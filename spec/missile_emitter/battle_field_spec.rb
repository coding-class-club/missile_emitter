module MissileEmitter
  RSpec.describe BattleField do

    it "继承自 BasicObject 而非 Object" do
      expect(BattleField.ancestors).to contain_exactly(BattleField, BasicObject)
    end

    it "实例化时接收并保存可调用对象（Callable）" do
      callable = -> {}
      instance = BattleField.new callable

      expect(instance.instance_eval("@handler")).to eq callable
    end

    it "将 method_missing 事件转交给保存的可调用对象处理" do
      callable = double 'callable'

      expect(callable).to receive(:call).with(a_kind_of(Symbol), any_args).and_yield

      BattleField.new(callable).instance_eval do
        missing() {}
      end
    end

    it "使用 emit! 方法执行代码块，以便触发 method_missing 事件" do
      emit = BattleField.instance_method :emit!
      origin = BattleField.instance_method :instance_eval

      expect(emit).to eq origin 
    end

  end
end