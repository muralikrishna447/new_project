describe 'csContenteditable directive', ->
  beforeEach(module('ChefStepsApp'))

  beforeEach =>
    inject (_$compile_, _$rootScope_) =>
      @compile = _$compile_
      @rootScope = _$rootScope_

  runDirective = (text) =>
    @rootScope.foo = text
    html = '<div cs-contenteditable="false" ng-model="foo"></div>'
    e = @compile(html)(@rootScope)
    @rootScope.$digest()
    e

  getHTML = (text) =>
    runDirective(text).html()

  it "Doesn't sanitize <b> tag", ->
    expect(getHTML('<b>Dogfood</b>')).toContain '<b>Dogfood</b>'

  it "Does sanitize <script> tag by default", ->
    expect(getHTML('<b>Catfood<script>danger!</script></b>')).toNotContain 'script'
  it "Does not sanitize <script> tag if parent insists safe", =>
    @rootScope.createdByAdmin = -> true
    expect(getHTML('<b>Catfood<script>danger!</script></b>')).toContain 'script'
