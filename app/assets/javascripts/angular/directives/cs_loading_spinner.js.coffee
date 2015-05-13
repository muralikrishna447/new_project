@app.directive 'csLoadingSpinner', [ ->
  restrict: 'E'
  replace: true

  template:
    """
      <div class="loading-spinner" >
        <svg class="cs-icon-sides-dims">
          <use xlink:href="#sides" xmlns:xlink="http://www.w3.org/1999/xlink"></use>
        </svg>
      </div>
    """
]