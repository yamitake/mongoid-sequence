class SecuencedChildModel
  include Mongoid::Document
  include Mongoid::Sequence

  field :auto_increment, :type => Integer
  sequence :auto_increment

  embedded_in :parent_model, class_name: 'ParentModel'
end
