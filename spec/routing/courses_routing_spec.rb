require 'spec_helper'

describe 'routes for Courses' do
  # The pending tests below just don't work...I have no clue!
  it 'routes /courses to the courses controller' do
    expect(get: '/courses').to route_to(action: 'index', controller: 'courses')
  end

  it 'routes /courses/spherification to the class landing controller', pending: true do
    expect(get: "/courses/spherification").to route_to(action: 'landing', controller: 'assemblies', id: 'spherification')
  end

  it 'routes /courses/spherification/reverse-spherification to the assemblies controller', pending: true do
    expect(get: "/courses/spherification#/reverse-spherification").to route_to(action: 'show', controller: 'assemblies', id: 'spherification')
  end

  it 'routes /courses/knife-sharpening to the assemblies controller', pending: true do
    expect(get: "/courses/knife-sharpening").to route_to(action: 'show', controller: 'assemblies', id: 'knife-sharpening')
  end

  it 'routes /courses/science-of-poutine to the assemblies controller', pending: true do
    expect(get: "/courses/science-of-poutine").to route_to(action: 'show', controller: 'assemblies', id: 'science-of-poutine')
  end

  it 'routes /courses/accelerated-sous-vide-cooking-course to the assemblies controller', pending: true do
    expect(get: "/courses/accelerated-sous-vide-cooking-course").to route_to(action: 'show', controller: 'assemblies', id: 'sous-vide-cooking')
  end

  it 'routes /classes/test to the assemblies controller' do
    expect(get: "/classes/test").to route_to(action: 'show', controller: 'assemblies', id: 'test')
  end

  it 'routes /classes/test/landing to the assemblies controller' do
    expect(get: "/classes/test/landing").to route_to(action: 'landing', controller: 'assemblies', id: 'test')
  end

end