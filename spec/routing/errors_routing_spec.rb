require 'spec_helper'

describe 'routes for errors' do
  it 'routes bogus top level url to the errors controller' do
    expect(get: '/xxx').to route_to(action: 'routing', controller: 'errors', a: 'xxx')
  end

  it 'routes bogus second level url to the errors controller' do
    expect(get: '/xxx/yyy').to route_to(action: 'routing', controller: 'errors', a: 'xxx/yyy')
  end

  it 'doesnt route valid urls to error controller' do
    expect(get: '/').to_not route_to(action: 'routing', controller: 'errors', a: '')
    expect(get: '/gallery').to_not route_to(action: 'routing', controller: 'errors', a: '')

  end
end