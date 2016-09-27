
$(function () {

  $('input[type=text].slug').each(function () {
    var slug = $(this);
    var start_length = slug.val().length;
    var pos = $.inArray(this, $('input', this.form)) - 1;
    var title = $($('input', this.form).get(pos));
    slug.focus(function () {
      slug.data('focus', true);
    });
    title.keyup(function () {
      if (start_length == 0 && slug.data('focus') != true)
        slug.val(title.val().toLowerCase().replace(/ /g, '-').replace(/[^a-z0-9\-]/g, ''));
    });
  });

  $(document).on('click', 'a[data-confirm]', function (e) {
    var message = $(this).data('confirm');
    if (!confirm(message)) {
      e.preventDefault();
      e.stopped = true;
    }
  });

  $(document).on('click', 'a.popup', function (e) {
    window.open(this.href, null, 'scrollbars=yes,width=600,height=600,left=150,top=150').focus();
    return false;
  });


  $('.geopicker').each(function () {
    var g = this;
    $(g).geopicker({
      width: '100%',
      getLatLng: function (container) {
        var lat = $('input[name$="[lat]"]', container).val()
        var lng = $('input[name$="[lng]"]', container).val()
        if (lat.length && lng.length)
          return new google.maps.LatLng(lat, lng)
      },
      set: function (container, latLng) {
        $('input[name$="[lat]"]', container).val(latLng.lat());
        $('input[name$="[lng]"]', container).val(latLng.lng());
      },
      address: function (container) {
        return $(container).prev().children().first().val()
      },
      guessElement: $(g).prev().children().last()
    });
  });

  $('input[type=hidden].lookup').each(function () {
    $(this).lookup({
      lookup_url: $(this).attr('data-lookup-url'),
      placeholder: $(this).attr('placeholder'),
      id_param: 'id'
    });
  });



});