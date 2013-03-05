class ChefSteps.Views.OrderSortTabToggler extends Backbone.View
  initialize: (options) =>
    super
    @gridContainer = @findGridContainer()
    @imagesMap = @findImages()
    @setupTabs()

  # Configure the click() events for the toggle tabs.
  setupTabs: ->
    toggler = @

    @$el.find('.toggle-tab').click (event) ->
      event.preventDefault()

      $link = $(this)

      # Don't run if we are already active on this tab.
      return if $link.hasClass('active-tab')

      imageIds = toggler.imageIds($link.attr('data-answer'))
      toggler.reorderImages(imageIds)

      # Make this link the active one.
      $link.closest('.toggle-tabs').find('.toggle-tab').removeClass('active-tab')
      $link.addClass('active-tab')

  # Reorders the images for a given image set.
  reorderImages: (idOrder) ->
    toggler = @
    images = _.map idOrder, (imageId) ->
      toggler.imagesMap[imageId]

    # Clear the container, refill it.
    @gridContainer.children().detach()

    _.each images, ($image, index) ->
      $image.find('.num').text(index + 1)
      toggler.gridContainer.append($image)

    @gridContainer.trigger('ss-event-arrange')

  # Converts a string of image IDs "1, 2, 3" into an array [1, 2, 3].
  imageIds: (listString) ->
    listString.split(",")

  # Finds all the .grid-item image elements.
  findImages: ->
    images = {}

    _.each @gridContainer.find('.grid-item'), (image) ->
      $image = $(image)
      images[$image.attr('data-image-id')] = $image

    images

  findGridContainer: ->
    @$el.closest('.order-sort').find('.grid-container')
