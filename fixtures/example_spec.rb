require 'example'

RSpec.describe Example do
  describe '#method_name' do
    it 'does something' do
      example = Example.new
      result = example.method_name
      expect(result).to eq(expected_result)
    end
  end
end
