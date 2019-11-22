RSpec.describe MissileEmitter do

  context "作为模块" do
    it "使用类实例变量（class instance variable）保存处理器（handler）映射表" do
      expect(MissileEmitter).to be_instance_variable_defined(:@mapping)
    end
  end

  context "作为方法调用" do
    
    it "是一个顶层方法" do
      expect(Kernel).to respond_to :MissileEmitter
    end

    it "在匿名模块中调用将抛出异常" do
      expect do
        Module.new {
          MissileEmitter {}
        }
      end.to raise_error MissileEmitter::Error, "只能再具名模块中调用"
    end

    it "必须传入代码块" do
      expect {
        MissileEmitter()
      }.to raise_error MissileEmitter::Error, "需要提供代码块"
    end

    it "调用之后，将目标模块上下文（context）加入映射表" do
      handler = nil

      module Target; end
      
      Target.class_eval do
        handler = -> (*args, &block) {}

        MissileEmitter &handler
      end

      expect(MissileEmitter.mapping).to include(Target => handler)

      Object.send :remove_const, :Target
    end

    it "生成与目标模块同名的顶层方法" do
      module Target
        MissileEmitter {}
      end

      expect(Target {}).to eq Target

      Object.send :remove_const, :Target
    end

    context "在嵌套模块中调用时" do

      it "默认为拟态方法添加命名空间" do
        module Namespace
          module Nested
            MissileEmitter {}
          end
        end

        expect(Namespace::Nested() {}).to eq Namespace::Nested

        Object.send :remove_const, :Namespace
      end

      it "通过配置参数可禁用命名空间" do
        module Namespace
          module Nested
            MissileEmitter(namespace: false) {}
          end
        end

        expect(Nested {}).to eq Namespace::Nested

        Object.send :remove_const, :Namespace
      end

    end

  end

  describe "调用目标模块同名方法时" do
    before :all do
      module Target
        MissileEmitter do |klass, field, value, *, &block|
          klass.define_method(field) {value || block.call}
        end
      end
    end

    after :all do
      Object.send :remove_const, :Target
    end

    it "生成 BattleField 实例" do
      expect(MissileEmitter::BattleField).to receive(:new).and_call_original

      Class.new do
        include Target {}
      end
    end

    it "将配置代码块传递给战场（BattleField）实例，触发 method_missing 事件" do
      battle_field = double 'battle field'

      expect(MissileEmitter::BattleField).to receive(:new).and_return battle_field

      expect(battle_field).to receive(:emit!).and_yield

      Class.new do
        include Target {}
      end
    end
  end

end
