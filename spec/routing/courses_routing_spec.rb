require 'spec_helper'

describe 'routes for Courses' do
  it 'routes /classes/test to the assemblies controller' do
    expect(get: "/classes/test").to route_to(action: 'show', controller: 'assemblies', id: 'test')
  end

  it 'routes /classes/test/landing to the assemblies controller' do
    expect(get: "/classes/test/landing").to route_to(action: 'landing', controller: 'assemblies', id: 'test')
  end

end