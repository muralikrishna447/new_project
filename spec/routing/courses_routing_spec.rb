require 'spec_helper'

describe 'routes for Courses' do

  it 'routes /courses to the courses controller' do
    expect(get: '/courses').to route_to(action: 'index', controller: 'courses')
  end

  it 'routes /courses/spherification to the courses controller' do
    expect(get: "/courses/spherification").to route_to(action: 'show', controller: 'courses', id: 'spherification')
  end

  it 'routes /courses/spherification/reverse-spherification to the activities controller' do
    expect(get: "/courses/spherification/reverse-spherification").to route_to(action: 'show', controller: 'activities', course_id: 'spherification', id: 'reverse-spherification')
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

  it 'routes /course/landing to the assemblies controller' do
    expect(get: "/courses/test/landing").to route_to(action: 'landing', controller: 'assemblies', id: 'test')
  end

end