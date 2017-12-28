class UserTrackSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :date,
             :location_details
end
