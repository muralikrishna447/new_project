beforeEach ->
  clone = _.clone(Backbone)
  Backbone.originalSync = clone.sync
  Backbone.sync = jasmine.createSpy('sync')

afterEach ->
  Backbone.sync = Backbone.originalSync

