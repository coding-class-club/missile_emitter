RSpec.describe MissileEmitter do
  it "是一个顶层方法" do
    expect(Kernel).to respond_to :MissileEmitter
  end

  context "方法签名" do
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
  end
end
