class UserCurrentLocationSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :sync_user,
             :date,
             :location_detail
end
