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
        embedded_relation_id = self.embedded? ? self._parent.id.to_s : nil
        sequence_name = [self.class.name.underscore, embedded_relation_id, prefix, field].select { |f| !f.blank? }.join("_")
        next_sequence = sequences.find(_id: sequence_name).find_one_and_update({'$inc' => {seq: 1}}, {return_document: :after, upsert: true})
        self[field] = next_sequence["seq"]
      end if self.class.sequence_fields
    end
  end
end