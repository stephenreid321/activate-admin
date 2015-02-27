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


  $('.geopicker').geopicker({
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
    }
  });

  $('input[type=hidden].lookup').each(function () {
    var lookup_url = $(this).attr('data-lookup-url');
    $(this).select2({
      placeholder: $(this).attr('placeholder'),
      allowClear: true,
      minimumInputLength: 1,
      width: '100%',
      ajax: {
        url: lookup_url,
        dataType: 'json',
        data: function (term) {
          return {
            q: term
          };
        },
        results: function (data) {
          return {results: data.results};
        }
      },
      initSelection: function (element, callback) {
        var id = $(element).val();
        if (id !== '') {
          $.get(lookup_url, {id: id}, function (data) {
            callback(data);
          });
        }
      }
    });
  });



});