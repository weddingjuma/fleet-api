class MissionStatusSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :mission_id,
             :mission_status_type_id,
             :date,
             :description
end
