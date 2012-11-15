require 'spec_helper'

describe Version, '#current' do
  it 'returns nil if no version record exists' do
    Version.current.should_not be
  end
end
