class PrefixSequencedModel
  include Mongoid::Document
  include Mongoid::Sequence

  field :tenant_id, :type => Integer
  field :auto_increment, :type => Integer
  sequence :auto_increment, :tenant_id
end
