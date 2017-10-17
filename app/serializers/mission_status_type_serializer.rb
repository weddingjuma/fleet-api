class MissionStatusTypeSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :color,
             :label
end
