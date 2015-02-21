class ParentModel
  include Mongoid::Document

  embeds_many :children, class_name: 'SecuencedChildModel'
end
