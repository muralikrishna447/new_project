beforeEach ->
  window.filepicker = jasmine.createSpyObj('fake filepicker', ['pickMultiple', 'remove', 'pick'])
  clone = _.clone(Backbone)
  Backbone.originalSync = clone.sync
  Backbone.sync = jasmine.createSpy('sync')

afterEach ->
  Backbone.sync = Backbone.originalSync

