module Helpers

  # Gets the currently described class.
  # Conversely to +subject+, it returns the class
  # instead of an instance.
  def klass
    described_class
  end

  def fixture(*name)
    File.join(SPEC_ROOT, "fixtures", *name)
  end

  def json_fixture(*name)
    MultiJson.load File.read(fixture(*name))
  end

end

RSpec.configure do |config|
  config.include Helpers
end
