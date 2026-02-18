
$(function () {

  $(".datepicker").flatpickr({ altInput: true, altFormat: 'J F Y' });
  $(".datetimepicker").flatpickr({ altInput: true, altFormat: 'J F Y, H:i', enableTime: true, time_24hr: true });

  $(document).on('click', 'a[data-confirm]', function (e) {
    var message = $(this).data('confirm');
    if (!confirm(message)) {
      e.preventDefault();
      e.stopped = true;
    }
  });

  $(document).on('click', 'a.popup', function (e) {
    window.open(this.href, null, 'scrollbars=yes,width=575,height=575,left=150,top=150').focus();
    return false;
  });


  $('select.lookup').each(function () {
    $(this).lookup({
      lookup_url: $(this).attr('data-lookup-url'),
      placeholder: $(this).attr('placeholder'),
      id_param: 'id'
    });
  });

});