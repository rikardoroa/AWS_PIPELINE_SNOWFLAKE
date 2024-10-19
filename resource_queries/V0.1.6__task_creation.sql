USE DATABASE {{ database }};
USE SCHEMA {{ schema }};

CREATE OR REPLACE TASK stream_fire_incidents_data_capture
  WAREHOUSE = {{ warehouse }}
  SCHEDULE = 'USING CRON 25 18 * * * UTC'
WHEN
  SYSTEM$STREAM_HAS_DATA('FIRE_INCIDENTS_STREAM')
AS
  MERGE INTO daily_fire_incidents dt USING(
    SELECT
          $1:incident_number::STRING AS "New Incident Number",
          $1:exposure_number::STRING AS "New Exposure Number",
          $1:id::STRING AS "New ID",
          $1:address::STRING AS "Address",
          $1:incident_date::TIMESTAMP AS "Incident Date",
          $1:call_number::STRING AS "Call Number",
          $1:alarm_dttm::TIMESTAMP AS "Alarm DtTm",
          $1:arrival_dttm::TIMESTAMP AS "Arrival DtTm",
          $1:close_dttm::TIMESTAMP AS "Close DtTm",
          $1:city::STRING AS "City",
          $1:zipcode::STRING AS "zipcode",
          $1:battalion::STRING AS "Battalion",
          $1:station_area::STRING AS "Station Area",
          $1:box::STRING AS "Box",
          $1:suppression_units::STRING AS "Suppression Units",
          $1:suppression_personnel::STRING AS "Suppression Personnel",
          $1:ems_units::STRING AS "EMS Units",
          $1:ems_personnel::STRING AS "EMS Personnel",
          $1:other_units::STRING AS "Other Units",
          $1:other_personnel::STRING AS "Other Personnel",
          $1:first_unit_on_scene::STRING AS "First Unit On Scene",
          $1:estimated_property_loss::STRING AS "Estimated Property Loss",
          $1:estimated_contents_loss::STRING AS "Estimated Contents Loss",
          $1:fire_fatalities::STRING AS "Fire Fatalities",
          $1:fire_injuries::STRING AS "Fire Injuries",
          $1:civilian_fatalities::STRING AS "Civilian Fatalities",
          $1:civilian_injuries::STRING AS "Civilian Injuries",
          $1:number_of_alarms::STRING AS "Number of Alarms",
          $1:primary_situation::STRING AS "Primary Situation",
          $1:mutual_aid::STRING AS "Mutual Aid",
          $1:action_taken_primary::STRING AS "Action Taken Primary",
          $1:action_taken_secondary::STRING AS "Action Taken Secondary",
          $1:action_taken_other::STRING AS "Action Taken Other",
          $1:detector_alerted_occupants::STRING AS "Detector Alerted Occupants",
          $1:property_use::STRING AS "Property Use",
          $1:area_of_fire_origin::STRING AS "Area of Fire Origin",
          $1:ignition_cause::STRING AS "Ignition Cause",
          $1:ignition_factor_primary::STRING AS "Ignition Factor Primary",
          $1:ignition_factor_secondary::STRING AS "Ignition Factor Secondary",
          $1:heat_source::STRING AS "Heat Source",
          $1:item_first_ignited::STRING AS "Item First Ignited",
          $1:human_factors_associated_with_ignition::STRING AS "Human Factors Associated with Ignition",
          $1:structure_type::STRING AS "Structure Type",
          $1:structure_status::STRING AS "Structure Status",
          $1:floor_of_fire_origin::STRING AS "Floor of Fire Origin",
          $1:fire_spread::STRING AS "Fire Spread",
          $1:no_flame_spread::STRING AS "No Flame Spread",
          $1:number_of_floors_with_minimum_damage::STRING AS "Number of floors with minimum damage",
          $1:number_of_floors_with_significant_damage::STRING AS "Number of floors with significant damage",
          $1:number_of_floors_with_heavy_damage::STRING AS "Number of floors with heavy damage",
          $1:number_of_floors_with_extreme_damage::STRING AS "Number of floors with extreme damage",
          $1:detectors_present::STRING AS "Detectors Present",
          $1:detector_type::STRING AS "Detector Type",
          $1:detector_operation::STRING AS "Detector Operation",
          $1:detector_effectiveness::STRING AS "Detector Effectiveness",
          $1:detector_failure_reason::STRING AS "Detector Failure Reason",
          $1:automatic_extinguishing_system_present::STRING AS "Automatic Extinguishing System Present",
          $1:automatic_extinguishing_sytem_type::STRING AS "Automatic Extinguishing Sytem Type",
          $1:automatic_extinguishing_sytem_perfomance::STRING AS "Automatic Extinguishing Sytem Perfomance",
          $1:automatic_extinguishing_sytem_failure_reason::STRING AS "Automatic Extinguishing Sytem Failure Reason",
          $1:number_of_sprinkler_heads_operating::STRING AS "Number of Sprinkler Heads Operating",
          $1:supervisor_district::STRING AS "Supervisor District",
          $1:neighborhood_district::STRING AS "neighborhood_district",
          $1:point.coordinates[0]::FLOAT AS "longitude",
          $1:point.coordinates[1]::FLOAT AS "latitude",
          $1:data_as_of::TIMESTAMP AS "data_as_of",
          $1:data_loaded_at::TIMESTAMP AS "data_loaded_at"
        FROM FIRE_INCIDENTS_STREAM 
        ) ft
          ON  dt."Incident Number" = ft."New Incident Number"
          AND dt."Exposure Number" = ft."New Exposure Number"
          AND dt."ID" = ft."New ID"
        WHEN NOT MATCHED THEN
        INSERT("Incident Number" ,
                  "Exposure Number",
                  "ID",
                  "Address",
                  "Incident Date",
                  "Call Number",
                  "Alarm DtTm",
                  "Arrival DtTm",
                  "Close DtTm",
                  "City",
                  "zipcode",
                  "Battalion",
                  "Station Area",
                  "Box",
                  "Suppression Units",
                  "Suppression Personnel" ,
                  "EMS Units",
                  "EMS Personnel",
                  "Other Units",
                  "Other Personnel",
                  "First Unit On Scene",
                  "Estimated Property Loss",
                  "Estimated Contents Loss",
                  "Fire Fatalities",
                  "Fire Injuries",
                  "Civilian Fatalities",
                  "Civilian Injuries",
                  "Number of Alarms",
                  "Primary Situation",
                  "Mutual Aid",
                  "Action Taken Primary",
                  "Action Taken Secondary",
                  "Action Taken Other",
                  "Detector Alerted Occupants",
                  "Property Use",
                  "Area of Fire Origin",
                  "Ignition Cause",
                  "Ignition Factor Primary",
                  "Ignition Factor Secondary",
                  "Heat Source",
                  "Item First Ignited",
                  "Human Factors Associated with Ignition",
                  "Structure Type",
                  "Structure Status",
                  "Floor of Fire Origin",
                  "Fire Spread",
                  "No Flame Spread",
                  "Number of floors with minimum damage",
                  "Number of floors with significant damage",
                  "Number of floors with heavy damage",
                  "Number of floors with extreme damage",
                  "Detectors Present",
                  "Detector Type",
                  "Detector Operation",
                  "Detector Effectiveness",
                  "Detector Failure Reason",
                  "Automatic Extinguishing System Present",
                  "Automatic Extinguishing Sytem Type",
                  "Automatic Extinguishing Sytem Perfomance",
                  "Automatic Extinguishing Sytem Failure Reason",
                  "Number of Sprinkler Heads Operating",
                  "Supervisor District",
                  "neighborhood_district",
                  "longitude",
                  "latitude",
                  "data_as_of",
                  "data_loaded_at" )
        VALUES("New Incident Number" ,
                  "New Exposure Number",
                  "New ID",
                  "Address",
                  "Incident Date",
                  "Call Number",
                  "Alarm DtTm",
                  "Arrival DtTm",
                  "Close DtTm",
                  "City",
                  "zipcode",
                  "Battalion",
                  "Station Area",
                  "Box",
                  "Suppression Units",
                  "Suppression Personnel" ,
                  "EMS Units",
                  "EMS Personnel",
                  "Other Units",
                  "Other Personnel",
                  "First Unit On Scene",
                  "Estimated Property Loss",
                  "Estimated Contents Loss",
                  "Fire Fatalities",
                  "Fire Injuries",
                  "Civilian Fatalities",
                  "Civilian Injuries",
                  "Number of Alarms",
                  "Primary Situation",
                  "Mutual Aid",
                  "Action Taken Primary",
                  "Action Taken Secondary",
                  "Action Taken Other",
                  "Detector Alerted Occupants",
                  "Property Use",
                  "Area of Fire Origin",
                  "Ignition Cause",
                  "Ignition Factor Primary",
                  "Ignition Factor Secondary",
                  "Heat Source",
                  "Item First Ignited",
                  "Human Factors Associated with Ignition",
                  "Structure Type",
                  "Structure Status",
                  "Floor of Fire Origin",
                  "Fire Spread",
                  "No Flame Spread",
                  "Number of floors with minimum damage",
                  "Number of floors with significant damage",
                  "Number of floors with heavy damage",
                  "Number of floors with extreme damage",
                  "Detectors Present",
                  "Detector Type",
                  "Detector Operation",
                  "Detector Effectiveness",
                  "Detector Failure Reason",
                  "Automatic Extinguishing System Present",
                  "Automatic Extinguishing Sytem Type",
                  "Automatic Extinguishing Sytem Perfomance",
                  "Automatic Extinguishing Sytem Failure Reason",
                  "Number of Sprinkler Heads Operating",
                  "Supervisor District",
                  "neighborhood_district",
                  "longitude",
                  "latitude",
                  "data_as_of",
                  "data_loaded_at");

ALTER TASK stream_fire_incidents_data_capture RESUME;