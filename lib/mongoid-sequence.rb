require "mongoid-sequence/version"
require "active_support/concern"

module Mongoid
  module Sequence
    extend ActiveSupport::Concern

    included do
      set_callback :create, :before, :set_sequence, :unless => :persisted?
    end

    module ClassMethods
      attr_accessor :sequence_fields, :sequence_prefix

      def sequence(field, prefix = '')
        self.sequence_fields ||= []
        self.sequence_fields << field
        self.sequence_prefix = prefix
      end
    end

    def set_sequence
      sequences = self.mongo_client['__sequences']
      prefix    = self.class.sequence_prefix.present? ? self.send(self.class.sequence_prefix).to_s : ''
      self.class.sequence_fields.each do |field|
        id = "#{self.class.name.underscore}_#{prefix}_#{field}"
        next_sequence = sequences.find(_id: id).find_one_and_update({'$inc' => {seq: 1}}, {return_document: :after, upsert: true})
        self[field] = next_sequence["seq"]
      end if self.class.sequence_fields
    end
  end
end