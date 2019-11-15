RSpec.describe MissileEmitter do

  context "作为模块扩展" do
    it "使用类实例变量（class instance variable）保存处理器（handler）映射表" do
      expect(MissileEmitter).to be_instance_variable_defined(:@mapping)
    end

    context "被扩展（extended）时" do

      context "匿名模块" do
        it "抛出异常" do
          expect do
            Module.new {
              extend MissileEmitter -> {}
            }
          end.to raise_error MissileEmitter::Error
        end
      end

      context "具名模块" do
        before :all do
          module Target
            extend MissileEmitter -> {}
          end
        end

        it "生成与目标模块同名的顶层方法" do
          expect(Kernel).to respond_to :Target
        end
      end

    end
  end

  context "作为方法调用" do
    it "是一个顶层方法" do
      expect(Kernel).to respond_to :MissileEmitter
    end

    it "必须传入一个参数" do
      expect {
        MissileEmitter()
      }.to raise_error ArgumentError
    end

    it "参数类型必须为lambda" do
      expect {
        params = [1, false, nil, '', [], {}, Object.new]
        
        params.each do |arbitrary|
          MissileEmitter arbitrary
        end
      }.to raise_error TypeError

      expect {
        MissileEmitter -> {}
      }.not_to raise_error
    end

    it "返回同名模块" do
      expect(MissileEmitter -> {}).to eq MissileEmitter
    end

    it "调用之后，将目标模块上下文（context）加入映射表" do
      handler = nil

      target = Module.new do
        handler = -> {}

        MissileEmitter handler
      end

      expect(MissileEmitter.mapping).to have_key target
      expect(MissileEmitter.mapping[target]).to eq handler
    end
  end

end
