(($) ->
  'use strict'
  calculate = () ->
    # calculations
    # item calculation
    $("tr.budget_nested_fields").filter(':visible').each ->
      $(this).find("[data-budget-item-value]").filter(':visible').each (index) ->
        quantity = $(this).parent().find("input").val()
        unit_amount         = $(this).closest("tr.budget_nested_fields").find("input[type='number'][id$='unit_amount']").val()
        computation_method  = $(this).closest("tr.budget_nested_fields").find("select[id$='computation_method']").val()
        working_indicator_value = 1
        if computation_method == 'per_working_unit'
          working_indicator_value = $("[data-working-indicator-value]")[index]
          working_indicator_value = parseFloat($(working_indicator_value).text())
        $(this).text(quantity * unit_amount * working_indicator_value)
    #total per budget
    $("tr.budget_nested_fields").filter(':visible').each ->
      sum = 0.0
      $(this).find("[data-budget-item-value]").filter(':visible').each ->
        sum = sum + parseFloat($(this).text())
      $(this).find("[data-budget-global-amount]").text(sum)
    #global amount for revenues/expenses
    $("[data-budgets-global-amount]").filter(':visible').each ->
      sum = 0.0
      direction = $(this).attr('data-budgets-global-amount')
      $("[data-budget-global-amount=#{direction}]").filter(':visible').each ->
        sum = sum + parseFloat($(this).text())
      $(this).text(sum)
    # global balance
    $("[data-balance='global']").each ->
      revenue = parseFloat($("[data-budgets-global-amount='revenue']").text())
      expense = parseFloat($("[data-budgets-global-amount='expense']").text())
      sum = revenue - expense
      $(this).text(sum)
    #total revenue/expense per support
    $("[data-budget-add]").each ->
      cells = $(this).find("[data-support-total]")
      cells.each (index) ->
        sum = 0.0
        direction = $(this).attr("data-support-total")
        $("[data-budget-direction=#{direction}]").filter(':visible').each ->
          amount = $(this).find("[data-budget-item-value]").filter(':visible')[index]
          amount = parseFloat($(amount).text())
          sum = sum + amount
        $(this).text(sum)
    # balance per support
    $("[data-balance='support']").each (index) ->
      expenses = $("[data-support-total='expense']")[index]
      expenses = parseFloat($(expenses).text())
      revenues = $("[data-support-total='revenue']")[index]
      revenues = parseFloat($(revenues).text())
      $(this).text(revenues - expenses)

  $(document).ready ->
    # sorts budgets by direction
    $("tr[data-budget-direction]").each ->
      direction = $(this).attr('data-budget-direction')
      target = $("tr[data-budget-add=#{direction}]")
      $(this).insertBefore(target)
    #adds items
    $("table#budget_visualization").on 'cocoon:after-insert', (event, inserted) ->
      # adds items to new budget
      if inserted.hasClass("budget_nested_fields")
        link_to_add_budget_item = inserted.find("a[data-association='item']")
        #adds items for supports
        $("input[id^='production_supports_attributes_'][id$='destroy'][type='hidden']").each ->
          if $(this).closest('td').is(':visible')
            link_to_add_budget_item.click()
            new_item = link_to_add_budget_item.closest("td").prev()
            new_item.attr('data-support-destroy', $(this).attr('id'))
    # finally calculates everything
    calculate()
    return false

  # when adding a support
  $(document).on 'click keyup', "a[data-association='support']", ->
    # adds items
    support_destroy_id = $(this).closest("td").prev().find("input[id^='production_supports_attributes_'][id$='destroy'][type='hidden']").attr('id')
    $("a[data-association='item']").each ->
      $(this).click()
      new_item = $(this).closest('td').prev()
      new_item.attr('data-support-destroy', support_destroy_id)
    # adds total calculation cells
    $("[data-appendable]").each ->
      template = $(this).attr('data-appendable')
      $(this).find("[data-append-before]").before($(template))
    return false

  # when removing a support
  $(document).on 'click', "a.remove-support", ->
    #removes items
    items_to_remove = $(this).closest('td').find("input[id^='production_supports_attributes_'][id$='destroy'][type='hidden']").attr('id')
    $("tr.budget_nested_fields").each ->
      link_to_remove_item = $(this).find("td[data-support-destroy='#{items_to_remove}']").find("a.remove-item")
      link_to_remove_item.click()
    # removes a total calculation cell
    $("[data-appendable]").each ->
      $(this).find("[data-append-before]").prev().remove()
    return false

  # when updating any field
  $(document).on 'change emulated:change keyup cocoon:after-remove', "*", ->
    calculate()
    return false
  return
) jQuery
