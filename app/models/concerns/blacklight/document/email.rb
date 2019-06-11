# frozen_string_literal: true

# This module provides the body of an email export based on the document's semantic values
module Blacklight::Document::Email
  # Return a text string that will be the body of the email
  def to_email_text
    semantics = to_semantic_values
    body = []
    ['title', 'latin_title', 'published', 'edition', 'format', 'language'].each do |field|
      if semantics[field.to_sym].present?
        value = semantics[field.to_sym]
        label = "blacklight.email.text.#{field}"
        body << I18n.t(label, value: value.join('; '))
      end
    end
    return body.join("\n") unless body.empty?
  end
end
