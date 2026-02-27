class Avo::Resources::DbConfig < Avo::BaseResource
  self.model_class = ::DBConfig::Record
  self.title = :key
  self.search = {
    query: -> {
      query.ransack(
        key_cont: q,
        id_eql: q,
        value_cont: q,
        value_type_cont: q,
        eager_load_cont: q,
        m: "or"
      ).result(distinct: false)
    },
    item: -> {
      {
        title: "",
        description: "Key: <strong>#{record.key}</strong> <br> Value: <strong>#{record.value}</strong> <br> Type: <strong>#{record.value_type}</strong> <br> Eager Load: <strong>#{record.eager_load}</strong>".html_safe
      }
    }
  }

  self.description = -> {
    base = if view.form?
      "If you're not familiar with DBConfig, please refer to the <a href='https://github.com/avo-hq/db_config' target='_blank'>DBConfig</a> documentation.".html_safe
    elsif view.index?
      "This is used to manage the <a href='https://github.com/avo-hq/db_config' target='_blank'>DBConfig</a> configurations.<br>Search is performed on all fields.".html_safe
    end

    if view.new?
      base += "<br>This is a new configuration. Please fill in the key and the type values and click the 'Save' button.<br>
      You'll be able to edit the value on the next page.".html_safe
    end

    base
  }

  VALUE_TYPE_CONVERSIONS = {
    "String" => :text,
    "Integer" => :number,
    "Boolean" => :boolean,
    "Hash" => :code,
    "Array" => :text,
    "Float" => :number
  }

  def fields
    field :id, as: :id
    field :key

    if record.present?
      field :value, as: VALUE_TYPE_CONVERSIONS[record.value_type], update_using: ->{
        return value unless record.value_type == "Boolean"

        case value
        when "1"
          "true"
        when "0"
          "false"
        else
          value
        end
      }, visible: -> { !resource.view.new? }
    else
      field :value, visible: -> { !resource.view.new? }
    end

    field :value_type,
      as: :select,
      name: "Type",
      options: DBConfig::Record::VALUE_TYPES, disabled: -> { record.persisted? },
      help: -> {
        return if !record.persisted?

        path, data = Avo::Resources::DbConfig::ForceChangeType.link_arguments(resource: resource)

        "Can't change the type of a configuration that has already been set.<br>
        Click #{link_to("here", path, data: data).html_safe} to force the type change."
      }

    field :eager_load, as: :boolean
  end

  def self.plural_name
    "Configurations"
  end

  def self.singular_name
    "Configuration"
  end

  class ForceChangeType < Avo::BaseAction
    self.name = "Force Change Type"
    self.message = "Are you sure you want to change the type of this configuration?<br>
    This will reset the type to the selected type and will remove the current value."
    self.confirm_button_label = "Force Change"
    self.cancel_button_label = "Cancel"
    self.visible = -> {
      resource.view.form? && resource.record&.persisted?
    }

    def fields
      field :value_type, as: :select, options: DBConfig::Record::VALUE_TYPES
    end

    DEFAULT_VALUE_TYPES = {
      "String" => "",
      "Integer" => 0,
      "Float" => 0.0,
      "Boolean" => false,
      "Array" => [],
      "Hash" => {},
      "NilClass" => nil
    }

    def handle(query:, fields:, **)
      query.first.update!(value_type: fields[:value_type], value: DEFAULT_VALUE_TYPES[fields[:value_type]])
      succeed "Type changed successfully."
    end
  end
end
