# frozen_string_literal: true

module ActiveStorageValidations
  class FilenameValidator < ActiveModel::EachValidator # :nodoc:
    def validate_each(record, attribute, _value)
      return true if !record.send(attribute).attached? || types.empty?

      files = Array.wrap(record.send(attribute))

      errors_options = { authorized_types: types_to_human_format }
      errors_options[:message] = options[:message] if options[:message].present?

      files.each do |file|
        next if is_valid?(file)

        errors_options[:filename] = filename(file)
        record.errors.add(attribute, :filename_invalid, errors_options)
        break
      end
    end

    def types
      (Array.wrap(options[:with]) + Array.wrap(options[:in])).compact.map do |type|
        Mime[type] || type
      end
    end

    def types_to_human_format
      types
        .map { |type| type.to_s.split('/').last.upcase }
        .join(', ')
    end

    def filename(file)
      file.blob.present? && file.blob.filename
    end

    def is_valid?(file)
      if options[:with].is_a?(Regexp)
        options[:with].match?(filename(file).to_s)
      else
        filename(file).in?(types)
      end
    end
  end
end
