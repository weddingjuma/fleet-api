class CompanySerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :default_mission_status_type_id
end
