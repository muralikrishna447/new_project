angular.module('ChefStepsApp').directive 'csgalleryitem', ->
  restrict: 'E',
  #replace: true,
  scope: { title: '=', href: '=', image: '=', footerLeft: '=', footerRight: '=', sash: '='},
  templateUrl: '/client_views/_cs_gallery_item'
