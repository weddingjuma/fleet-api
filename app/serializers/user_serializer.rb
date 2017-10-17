class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :sync_user,
             :email,
             :roles
end
