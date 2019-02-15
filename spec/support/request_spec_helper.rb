require 'rspec/json_expectations'

module RequestSpecHelper

  def should_include_json(json)
    expect(json_body).to include_json(json)
  end

  def should_have_pair(key, value)
    expect(json_body.fetch(key)).to eq(value)
  end

  def response_body
    JSON.parse(response.body)
  end

end

RSpec.configuration.send :include, RequestSpecHelper
