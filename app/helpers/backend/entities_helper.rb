module Backend::EntitiesHelper

  # Compute a column chart with main transactions of an entity
  def transactions_by_month_chart(entity, options = {})
    stopped_on = options[:stopped_on] || Date.today
    started_on = options[:started_on] || stopped_on - 12.months

    series = []
    categories = {}

    date = started_on
    stopped_on = started_on + 1 if started_on >= stopped_on
    while date < stopped_on
      categories[date.year.to_s + date.month.to_s.rjust(3, '0')] = date.l(format: "%b %Y")
      date = date >> 1
    end

    sale_items = entity.sale_items.between(started_on, stopped_on)
    if sale_items.any?
      item_h = sale_items.sums_of_periods(column: :amount).sort.inject({}) do |hash, pair|
        hash[pair.expr.to_i.to_s] = pair.sum.to_d
        hash
      end
      series << {type: 'column', name: :sales.tl, data: normalize_serie(item_h, categories.keys) }
    end

    purchase_items = entity.purchase_items.between(started_on, stopped_on)
    if purchase_items.any?
      item_h = purchase_items.sums_of_periods(column: :amount).sort.inject({}) do |hash, pair|
        hash[pair.expr.to_i.to_s] = pair.sum.to_d
        hash
      end
      series << {type: 'column', name: :purchases.tl, data: normalize_serie(item_h, categories.keys) }
    end

    outgoing_payments = entity.outgoing_payments.between(started_on, stopped_on)
    if outgoing_payments.any?
      item_h = outgoing_payments.sums_of_periods.sort.inject({}) do |hash, pair|
        hash[pair.expr.to_i.to_s] = pair.sum.to_d
        hash
      end
      series << {type: 'column', name: :outgoing_payments.tl, data: normalize_serie(item_h, categories.keys) }
    end

    incoming_payments = entity.incoming_payments.between(started_on, stopped_on)
    if incoming_payments.any?
      item_h = incoming_payments.sums_of_periods.sort.inject({}) do |hash, pair|
        hash[pair.expr.to_i.to_s] = pair.sum.to_d
        hash
      end
      series << {type: 'column', name: :incoming_payments.tl, data: normalize_serie(item_h, categories.keys) }
    end

    unless options[:blank].is_a?(FalseClass)
      return nil unless series.any?
    end

    html = column_highcharts(series, y_axis: {title: {text: :pretax_amount.tl}}, x_axis: { categories: categories.values}, legend: true)

    if options[:cobbler]
      options[:cobbler].cobble(options[:title] || :transactions_by_month) do
        html
      end
      return nil
    else
      return html
    end
  end

end
