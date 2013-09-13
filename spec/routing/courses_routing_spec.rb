require 'spec_helper'

describe 'routes for Courses' do

  it 'routes /courses/spherification to the courses controller' do
    expect(get: "/courses/spherification").to route_to(action: 'show', controller: 'courses', id: 'spherification')
  end

  it 'routes /courses/knife-sharpening to the courses controller' do
    expect(get: "/courses/knife-sharpening").to route_to(action: 'show', controller: 'courses', id: 'knife-sharpening')
  end

  it 'routes /courses/science-of-poutine to the courses controller' do
    expect(get: "/courses/science-of-poutine").to route_to(action: 'show', controller: 'courses', id: 'science-of-poutine')
  end

  it 'routes /courses/accelerated-sous-vide-cooking-course to the courses controller' do
    expect(get: "/courses/accelerated-sous-vide-cooking-course").to route_to(action: 'show', controller: 'courses', id: 'accelerated-sous-vide-cooking-course')
  end

  it 'routes /courses/test to the assemblies controller' do
    expect(get: "/courses/test").to route_to(action: 'show', controller: 'assemblies', id: 'test')
  end

end