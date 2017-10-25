class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :sync_user,
             :email,
             :vehicle,
             :color,
             :roles
end
