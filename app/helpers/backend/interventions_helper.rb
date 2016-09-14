module Backend
  module InterventionsHelper

    def add_taskboard_tasks(interventions, column)

      tasks = []

      interventions.find_each do |intervention|

        can_select = true
        colors = []
        task_datas = []

        if intervention.activity_productions.any?

          intervention.activity_productions.find_each do |activity_production|

            activity_color = activity_production.activity.color
            cultivable_zone = activity_production.cultivable_zone

            task_datas << { icon: "land-parcels", text: cultivable_zone.work_number, style: "background-color: #{activity_color};"}
          end
        end


        doers_count = intervention.doers.count

        if doers_count > 0

          doers_text = intervention.doers[0].product.name
          doers_text << " +" + (doers_count - 1).to_s if doers_count > 1

          task_datas << { icon: "user", text: doers_text, class: "doers" }
        end


        intervention_datas = { id: intervention.id, name: intervention.name }

        tasks << column.task([{text: intervention_datas[:name]}], task_datas, [], can_select, colors,
          params: {:class => "", :data => {:intervention => intervention_datas.to_json}})
      end

      tasks
    end

    def add_modal_data(title, detail, options)

      html = []

      icon = options[:icon] || nil
      image = options[:image] || nil

      content_tag(:div, nil, :class => "data") do

        html << content_tag(:div, nil, :class => "picture") do

          picture = content_tag(:i, nil, :class => "picto #{icon}") unless icon.nil?
          picture = image_tag(image, :class => "image") unless image.nil?

          picture
        end

        html << content_tag(:div, nil, :class => "details") do
          content_tag(:h4, title, :class => "data-title") +
          content_tag(:p, detail)
        end

        html.join.html_safe
      end
    end
  end
end