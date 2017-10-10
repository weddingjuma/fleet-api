class MissionSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :address,
             :comment,
             :date,
             :location,
             :name,
             :owners,
             :reference,
             :duration,
             :time_windows
end
