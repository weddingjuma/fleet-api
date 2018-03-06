module TranslationConcern
  extend ActiveSupport::Concern

  class TranslationError < StandardError
  end

  included do
    attribute :current_language, :translations_changed

    # Couchbase ORM doesn't detect changes in Hash type. So use another variable to detect it.
    after_save -> (model) { model.translations_changed = false }
  end

  def translated?(field)
    self.translated_attribute_fields.include?(field.to_sym)
  end

  def attributes
    super.merge(translated_fields)
  end

  def write_attribute(name, value, *args, &block)
    return super(name, value, *args, &block) unless translated?(name)

    value = self.auto_strip_translation_fields&.include?(name) ? strip_translation(value) : value

    self.translations_changed = true
    self["#{name}_translations"][I18n.locale.to_s] = value
  end

  def translated_fields
    translated_attribute_fields.inject({}) do |attributes, field|
      attributes.merge(field.to_s => send(field))
    end
  end

  def strip_translation(value)
    value = value.respond_to?(:strip) ? value.strip : value
    value = value.respond_to?(:'blank?') && value.respond_to?(:'empty?') && value.blank? ? nil : value

    return value
  end

  class_methods do
    # Base method to include in model:
    # translates :field_1, :field_2
    # options:
    # auto_strip_translation_fields
    # fallbacks_for_empty_translations (take first locale in languages column)
    def translates(*fields)
      options = fields.extract_options!
      apply_translations_options(options)

      check_columns!(fields)

      fields = fields.map(&:to_sym)

      fields.each do |field|
        # Create accessors for the attribute.
        define_translated_field_accessor(field)

        # Add attribute to the list.
        self.translated_attribute_fields << field
      end
    end

    # def translates?
    #   included_modules.include?(:apply_translations_options)
    # end

    def check_columns!(fields)
      untranslated_columns = fields.map { |field| "#{field}_translations" } - attributes.keys.map(&:to_s)

      raise TranslationError, "following columns not translated: #{untranslated_columns.join(', ')}" unless untranslated_columns.empty?
    end

    def apply_translations_options(options)
      class_attribute :translated_attribute_fields, :translation_default_language, :fallbacks_for_empty_translations, :auto_strip_translation_fields, :current_language
      self.translated_attribute_fields = []
      self.translation_default_language = options[:default_language]
      self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]
      self.auto_strip_translation_fields = options[:auto_strip_translation_fields]
    end

    protected

    def define_translated_field_accessor(field)
      define_translated_field_reader(field)
      define_translated_field_record(field)
      define_translated_field_writer(field)
    end

    def define_translated_field_reader(field)
      define_method(field) do
        self.translations_changed = false
        self.current_language = I18n.locale.to_s

        if self.fallbacks_for_empty_translations && self.translation_default_language
          default_language = resolve_value(self, self.translation_default_language)
          translation_keys = send("#{field}_translations").keys

          self.current_language = default_language if default_language && !translation_keys.include?(self.current_language)
        end

        send("#{field}_translations")[self.current_language]
      end
    end

    def define_translated_field_record(field)
      define_method("#{field}_was") do
        send("#{field}_translations_was")[I18n.locale.to_s]
      end
    end

    def define_translated_field_writer(field)
      define_method(:"#{field}=") do |value|
        write_attribute(field, value)
      end
    end
  end

  private

  def resolve_value(context, thing)
    case thing
      when Symbol
        context.__send__(thing)
      when Proc
        thing.call(context)
      else
        thing
    end
  end

end
