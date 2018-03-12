# Copyright © Mapotempo, 2018
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#

# == Schema Information
#
# {
#   "type": "mission_event_type_send_sms",
#   "_id": "mission_event_type_send_sms-XXXX"
#   "company_id": "company-XXXXX_XXXXX_XXXX_XXXXX",
#   "mission_action_type_id": "mission_action_type-XXXX",
#   "template": "",
#   "group": "default"
# }
#

class MissionEventTypeSendSMS < MissionEventType

  # == Attributes ===========================================================
  attribute :template, type: String
  attribute :concat, type: Boolean

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================
  validates_presence_of :template

  # == Views ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def send_sms(mission)
    notif = Notifications.new(
      api_key: Rails.application.config.sms_api_key,
      api_secret: Rails.application.config.sms_api_secret,
      from: company.name,
      logger: Rails.application.config.logger_sms)

    date = mission.date.to_date
    repl = {
      date: I18n.l(date),
      time: mission.date,
      ref: mission.reference,
      comment: mission.comment,
      name: mission.name,
      street: mission.address.street,
      city: mission.address.city
    }

    notif.send_sms(
      mission.phone,
      mission.address.country,
      notif.content(template, repl, !concat),
      "SMc#{mission.company_id}t#{mission.date.to_i}"
    )
  end
end
