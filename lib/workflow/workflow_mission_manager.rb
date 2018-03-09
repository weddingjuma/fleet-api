class WorkflowMissionManager
  def self.init_workflow(mission)
    unless mission.mission_status_type_id
      case mission.mission_type
        when 'mission'
          mission.mission_status_type_id = MissionWorkflow.initial_mission_status(mission.company)&.id
        when 'departure'
          mission.mission_status_type_id = DepartureWorkflow.initial_mission_status(mission.company)&.id
        when 'rest'
          mission.mission_status_type_id = RestWorkflow.initial_mission_status(mission.company)&.id
        when 'arrival'
          mission.mission_status_type_id = ArrivalWorkflow.initial_mission_status(mission.company)&.id
        else
          mission.mission_status_type_id = MissionWorkflow.initial_mission_status(mission.company)&.id
      end
    end
  end
end
