class MissionStatusActionSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :previous_mission_status_type_id,
             :next_mission_status_type_id,
             :group,
             :label
end
