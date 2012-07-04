require "mongoid-sequence/version"
require "active_support/concern"

module Mongoid
  module Sequence
    extend ActiveSupport::Concern

    included do
      set_callback :validate, :before, :set_sequence, :unless => :persisted?
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
      sequences = Mongoid.default_session.collection("__sequences")
      prefix = ''
      prefix = self.send(self.class.sequence_prefix).to_s if self.class.sequence_prefix.present?
      self.class.sequence_fields.each do |field|
        next_sequence = sequences.find_and_modify(:query  => {"_id" => "#{self.class.name.underscore}_#{prefix}_#{field}"},
                                                  :update => {"$inc" => {"seq" => 1}},
                                                  :new    => true,
                                                  :upsert => true)

        self[field] = next_sequence["seq"]
      end if self.class.sequence_fields
    end
  end
end
