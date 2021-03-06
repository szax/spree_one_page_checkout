$ ->


  $(".js-inner:first").slideDown()

  $(document).on
    keyup: (e)->
      e.preventDefault()
      delay ()->
        GetStoreCredit()
      , 900
  , "#order_store_credit_amount"

  $(document).on
    click: (e)->
      if $(@).is(':checked')
        $('.js-hidden-radio', $(@).parents('.shipping-methods')).click()
      else
        $('.js-special-radio', $(@).parents('.shipping-methods')).click()

  , '#js-select_white_glove'

  $(document).on
    click: (e)->
      $('#js-select_white_glove', $(@).parents('.shipping-methods')).attr("checked", false);

  , '.js-special-radio'




  $(document).on
    change: (e)->
      if $(@).val() != '49'
        $('#order_ship_address_attributes_state_id').hide()
        $('#order_ship_address_attributes_state_name').removeClass('hidden')
      else
        $('#order_ship_address_attributes_state_name').addClass('hidden')
        $('#order_ship_address_attributes_state_id').show()

  , '#order_ship_address_attributes_country_id'

  $(document).on
    change: (e)->
      if $(@).val() != '49'
        $('#order_bill_address_attributes_state_id').hide()
        $('#order_bill_address_attributes_state_name').removeClass('hidden')
      else
        $('#order_bill_address_attributes_state_name').addClass('hidden')
        $('#order_bill_address_attributes_state_id').show()

  , '#order_bill_address_attributes_country_id'

  if $('#order_use_billing').is(':checked')
    $(".js-shipment_form").hide()
  else
    $(".js-shipment_form").show()

  $(document).on
    click: (e)->
      if $(@).is(':checked')
        $(".js-shipment_form").hide()
      else
        $(".js-shipment_form").show()

  , "#order_use_billing"


  #  $(document).on
  #    click: (e)->
  #      e.preventDefault()
  #      url =  $(@).attr('href')
  #      $.ajax
  #        dataType: 'html'
  #        url: url
  #  , ".js-show-one-page-checkout"

  $(document).on
    click: (e)->

      if (($(this)).is(':checked'))
        console.log('checked')
        ($('.billing_address .inner')).hide();
        ($('.billing_address .inner input, .billing_address .inner select')).prop('disabled', true)
      else
        $('.billing_address .inner').show()
        $('.billing_address .inner input, .billing_address .inner select').prop('disabled', false)

  , 'input#order_use_billing'


  $(document).on
    click: (e)->

      val = $(@).val()
      url = $(@).data('url')
      shipment = $(@).data('shipment-id')
      $.ajax
        dataType: 'json'
        method: 'POST'
        url: url
        data: {id: val, shipment_id: shipment}
        success: ()->
          checkAdjustments()

      console.log(val)
  , '.js-select-shipment'


  $(document).on
    click: (e)->
      e.preventDefault()
      checkAdjustments()
      $('.js-inner').each ()->
        $(@).slideUp()
      if $('#errorExplanation').length > 0
        $('#shipping .js-inner').slideDown()
      else
        $('#payment .js-inner').slideDown()
  , '.js-next-payment'

  $(document).on
    click: (e)->
      e.preventDefault()
      $('#methods .temporary-show').html ''
      shipping = $(@).data('check')
      next = $(@).data('next')

      if next?
        my_this = $('#shipping_method legend')
      else
        my_this = $(@)
      $('.js-inner').each ()->
        $(@).slideUp()
      if shipping? and shipping == 'shipping'
        checkAddress('shipping', my_this)
        checkValid('shipping')
      else
        $(".js-inner", $(@).parents('fieldset')).slideToggle()


  , ".js-bookmark, .js-shipping-sub"


checkValid = (fieldset)->
  class_name= ""
  if fieldset is 'shipping'
    class_name = $("#shipping  .required")
  else if fieldset is 'billing'
    class_name = $("#billing  .required")

  class_name.each ()->
    console.log $('.error', $(@).parents('.field'))
    $('.error', $(@).parents('.field')).remove()
    field = $(".required", $(@).parents('.field'))
    val = $(@).val()
    if field.length >0 and val.length is 0
      $(@).closest('.field').append('<label class="error">This field is required</label>')




GetStoreCredit = ()->
  url = $("#order_store_credit_amount").data('url-check')
  value = $("#order_store_credit_amount").val()
  $.ajax
    dataType: 'json'
    method: 'POST'
    url:  url
    data: {amount: value}
    success: ()->
      checkAdjustments()




@delay = (->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms))()


checkAdjustments = ()->
  url = $("#js-check-adjustments-url").attr('href')
  $.ajax
    dataType: 'html'
    method: 'POST'
    url: url
    success: (response)->
      $('#js-order-adjustments').html response
      $(".js-hidden-radio").each  ()->
        if $('#js-select_white_glove', $(@).parents('.white_glove_checkbox')).is(':checked') == false and $(@).is(':checked') == true
          $('.js-special-radio', $('.shipping-method')).click()

checkAddress = (value, my_this)->
  console.log value
  params = {}
  params['bill_id'] = $('#order_bill_address_attributes_id').val()
  params['ship_id'] = $('#order_ship_address_attributes_id').val()
  params['country_id'] = $('#order_ship_address_attributes_country_id').val()
  params['state_id'] = $('#order_ship_address_attributes_state_id').val()
  params['firstname'] = $('#order_ship_address_attributes_firstname').val()
  params['lastname'] = $('#order_ship_address_attributes_lastname').val()
  params['address1'] = $('#order_ship_address_attributes_address1').val()
  params['city'] = $('#order_ship_address_attributes_city').val()
  params['zipcode'] = $('#order_ship_address_attributes_zipcode').val()
  params['phone'] = $('#order_ship_address_attributes_phone').val()
  value_check = true
  $("[id$=#{value}] input.required").each ()->
    if $(@).val() == ""
      value_check = false
      return false
  if value_check == false
    $("[id$=#{value}] .js-inner").slideToggle()
  else
    fetch_available_shipping_methods(params)
    $(".js-inner", my_this.parents('fieldset')).slideToggle()


fetch_available_shipping_methods = (params_shippment) ->
  $.ajax
    type: 'POST'
    dataType: 'html'
    url: $('#shipping_method').data('url')
    data: params_shippment
    beforeSend: ( jqXHR ) ->
      $('#methods .time-load').show()
    success: (data) ->
      checkAdjustments()
      if data? && data.length
        $('#methods').html data
      else
        $('#methods').html "<center><p class='info'> #{$('#shipping_method').data('not-delivery')} </p></center>"