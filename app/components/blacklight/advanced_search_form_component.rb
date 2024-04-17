# frozen_string_literal: true

module Blacklight
  class AdvancedSearchFormComponent < PsulSearchBarComponent
    renders_many :constraints
    renders_many :search_field_controls
    renders_many :search_filter_controls, (lambda do |config:, display_facet:, **_kwargs|
      # presenter ||= config.presenter.new(config, display_facet, helpers)
      # component ||= config.advanced_search_component
      #   byebug
      #         component.new(facet_field: presenter, **kwargs)
    end)

    def initialize(response:, **options)
      super(**options)
      @response = response
    end

    def before_render
      initialize_search_field_controls if search_field_controls.blank?
      initialize_search_filter_controls if search_filter_controls.blank?
      initialize_constraints if constraints.blank?
    end

    def default_operator_menu
      options_with_labels = [:must, :should].index_by { |op| t(op, scope: 'blacklight.advanced_search.op') }
      label_tag(:op, t('blacklight.advanced_search.op.label'),
                class: 'sr-only visually-hidden') + select_tag(:op, options_for_select(options_with_labels, params[:op]),
                                                               class: 'input-small')
    end

    def sort_fields_select
      options = sort_fields.values.map do |field_config|
        [helpers.sort_field_label(field_config.key), field_config.key]
      end
      return unless options.any?

      select_tag(:sort, options_for_select(options, params[:sort]),
                 class: 'form-select custom-select sort-select w-auto', aria: { labelledby: 'advanced-search-sort-label' })
    end

    private

      def initialize_search_field_controls
        search_fields.values.each.with_index do |field, _i|
          with_search_field_control do
            # #original BL
            # fields_for('clause[]', i, include_id: false) do |f|
            #     content_tag(:div, class: 'form-group advanced-search-field row mb-3') do
            #         f.label(:query, field.display_label('search'), class: "col-sm-3 col-form-label text-md-right") +
            #         content_tag(:div, class: 'col-sm-9') do
            #             f.hidden_field(:field, value: field.key) +
            #             f.text_field(:query, value: query_for_search_clause(field.key), class: 'form-control')
            #         end
            #     end
            #   end
            fields_for('clause[]', field.field, include_id: false) do |f|
              content_tag(:div, class: 'form-group advanced-search-field row mb-3') do
                f.label(:query, field.display_label('search'), class: 'col-sm-3 col-form-label text-md-right') +
                  content_tag(:div, class: 'col-sm-9') do
                    f.hidden_field(:field, value: field.key) +
                      f.text_field(:query, value: query_for_search_clause(field.key), class: 'form-control')
                  end
              end
            end
            # gives field_field in for & id; field[field] in name
            #   fields_for(field.field, include_id: false) do |f|
            #     content_tag(:div, class: 'form-group advanced-search-field row mb-3') do
            #         f.label(field.field, field.display_label('search'), class: "col-sm-3 col-form-label text-md-right") +
            #           content_tag(:div, class: 'col-sm-9') do
            #             f.hidden_field(:field, value: field.key) +
            #               f.text_field(field.field, value: query_for_search_clause(field.key), class: 'form-control')
            #         end
            #     end
            #   end
            # gives field_field but only in for
            # fields_for(field.field, include_id: false) do |f|
            #     content_tag(:div, class: 'form-group advanced-search-field row mb-3') do
            #       f.label(field.field, field.display_label('search'), class: "col-sm-3 col-form-label text-md-right") +
            #       content_tag(:div, class: 'col-sm-9') do
            #         f.hidden_field(:field, value: field.key) +
            #         f.text_field(:query, value: query_for_search_clause(field.key), class: 'form-control', id: field.field, name: field.field)
            #       end
            #     end
            #   end
          end
        end
      end

      def initialize_search_filter_controls
        fields = blacklight_config.facet_fields.select do |_k, v|
          v.include_in_advanced_search || v.include_in_advanced_search.nil?
        end

        fields.each do |_k, config|
          display_facet = @response.aggregations[config.field]
          with_search_filter_control(config: config, display_facet: display_facet)
        end
      end

      def initialize_constraints
        params = helpers.search_state.params_for_search.except :page, :f_inclusive, :q, :search_field, :op, :index,
                                                               :sort

        adv_search_context = helpers.search_state.reset(params)

        constraints_text = render(Blacklight::ConstraintsComponent.for_search_history(search_state: adv_search_context))

        return if constraints_text.blank?

        with_constraint do
          constraints_text
        end
      end

      def query_for_search_clause(key)
        field = (@params[:clause] || {}).values.find { |value| value['field'].to_s == key.to_s }

        field&.dig('query')
      end

      def search_fields
        blacklight_config.search_fields.select do |_k, v|
          v.include_in_advanced_search || v.include_in_advanced_search.nil?
        end
      end

      def sort_fields
        blacklight_config.sort_fields.select do |_k, v|
          v.include_in_advanced_search || v.include_in_advanced_search.nil?
        end
      end
  end
end
