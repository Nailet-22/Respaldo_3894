CLASS lhc_zr_dt_inct_nc DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    CONSTANTS: BEGIN OF mc_status,
                 open        TYPE zde_status_nc VALUE 'OP',
                 in_progress TYPE zde_status_nc VALUE 'IP',
                 pending     TYPE zde_status_nc VALUE 'PE',
                 completed   TYPE zde_status_nc VALUE 'CO',
                 closed      TYPE zde_status_nc VALUE 'CL',
                 canceled    TYPE zde_status_nc VALUE 'CN',
               END OF mc_status.

  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Incident
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS setdefaulthistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR incident~setdefaulthistory.

    METHODS sethistory FOR MODIFY
      IMPORTING keys FOR ACTION incident~sethistory.

    METHODS setdefaultvalues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR incident~setdefaultvalues.

    METHODS changeStatus FOR MODIFY
      IMPORTING keys FOR ACTION incident~ChangeStatus RESULT result.

    METHODS get_history_index EXPORTING ev_incuuid      TYPE sysuuid_x16
                              RETURNING VALUE(rv_index) TYPE zde_his_id_nc.

ENDCLASS.

CLASS lhc_zr_dt_inct_nc IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD get_instance_features.

    DATA lv_history_index TYPE zde_his_id_nc.

    READ ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
       ENTITY Incident
         FIELDS ( Status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(incidents)
       FAILED failed.

    DATA(lv_create_action) = lines( incidents ).

    IF lv_create_action EQ 1.
      lv_history_index = get_history_index( IMPORTING ev_incuuid = incidents[ 1 ]-IncUUID ).
    ELSE.
      lv_history_index = 1.
    ENDIF.

    result = VALUE #( FOR incident IN incidents
                        ( %tky                   = incident-%tky
                          %action-ChangeStatus   = COND #( WHEN incident-Status = mc_status-completed OR
                                                                incident-Status = mc_status-closed    OR
                                                                incident-Status = mc_status-canceled  OR
                                                                lv_history_index = 0
                                                           THEN if_abap_behv=>fc-o-disabled
                                                           ELSE if_abap_behv=>fc-o-enabled )
                            %assoc-_History       = COND #( WHEN incident-Status = mc_status-completed OR
                                                               incident-Status = mc_status-closed    OR
                                                               incident-Status = mc_status-canceled  OR
                                                               lv_history_index = 0
                                                          THEN if_abap_behv=>fc-o-disabled
                                                          ELSE if_abap_behv=>fc-o-enabled )
                        ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD setDefaultHistory.
    MODIFY ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
   ENTITY Incident
   EXECUTE setHistory
      FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD setHistory.

    DATA: lt_updated_root_entity TYPE TABLE FOR UPDATE zr_dt_inct_nc,
          lt_association_entity  TYPE TABLE FOR CREATE zr_dt_inct_nc\_History,
          lv_exception           TYPE string,
          ls_incident_history    TYPE zdt_inct_h_nc,
          lv_max_his_id          TYPE zde_his_id_nc.

    READ ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
         ENTITY Incident
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(incidents).

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
      lv_max_his_id = get_history_index( IMPORTING ev_incuuid = <incident>-IncUUID ).

      IF lv_max_his_id IS INITIAL.
        ls_incident_history-his_id = 1.
      ELSE.
        ls_incident_history-his_id = lv_max_his_id + 1.
      ENDIF.

      TRY.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lo_error).
          lv_exception = lo_error->get_text(  ).
      ENDTRY.

      IF ls_incident_history-his_id IS NOT INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky
                        %target = VALUE #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              NewStatus = <incident>-Status
                                              Text = 'First Incident' ) )
                                               ) TO lt_association_entity.

      ENDIF.
    ENDLOOP.

    UNASSIGN <incident>.

    FREE incidents. " Free entries in incidents

    MODIFY ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
    ENTITY Incident
    CREATE BY \_History FIELDS ( HisUUID
                                 IncUUID
                                 HisID
                                 PreviousStatus
                                 NewStatus
                                 Text )
       AUTO FILL CID
       WITH lt_association_entity.

  ENDMETHOD.


  METHOD get_history_index.

    SELECT FROM zdt_inct_h_nc
      FIELDS MAX( his_id ) AS max_his_id
      WHERE inc_uuid EQ @ev_incuuid AND
            his_uuid IS NOT NULL
      INTO @rv_index.

  ENDMETHOD.

  METHOD setDefaultValues.

    READ ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
   ENTITY Incident
   FIELDS ( CreationDate
            Status ) WITH CORRESPONDING #( keys )
   RESULT DATA(incidents).

    DELETE incidents WHERE CreationDate IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.


    SELECT FROM zdt_inct_nc
    FIELDS MAX( incident_id ) AS max_inct_id
    WHERE incident_id IS NOT NULL
    INTO @DATA(lv_max_inct_id).

    IF lv_max_inct_id IS INITIAL.
      lv_max_inct_id = 1.
    ELSE.
      lv_max_inct_id += 1.
    ENDIF.

    MODIFY ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
          ENTITY Incident
          UPDATE
          FIELDS ( IncidentID
                   CreationDate
                   Status )
          WITH VALUE #(  FOR incident IN incidents ( %tky = incident-%tky
                                                     IncidentID = lv_max_inct_id
                                                     CreationDate = cl_abap_context_info=>get_system_date( )
                                                     Status       = mc_status-open )  ).

  ENDMETHOD.

  METHOD changeStatus.

    DATA: lt_updated_root_entity TYPE TABLE FOR UPDATE zr_dt_inct_nc,
          lt_association_entity  TYPE TABLE FOR CREATE zr_dt_inct_nc\_History,
          lv_status              TYPE zde_status_nc,
          lv_text                TYPE zde_text_nc,
          lv_exception           TYPE string,
          lv_error               TYPE c,
          ls_incident_history    TYPE zdt_inct_h_nc,
          lv_max_his_id          TYPE zde_his_id_nc,
          lv_wrong_status        TYPE zde_status_nc.

    READ ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
         ENTITY Incident
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(incidents)
         FAILED failed.

** Get parameters
    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
** Get Status
      lv_status = keys[ KEY id %tky = <incident>-%tky ]-%param-status.

**  It is not possible to change the pending (PE) to Completed (CO) or Closed (CL) status
      IF <incident>-Status EQ mc_status-pending AND lv_status EQ mc_status-closed OR
         <incident>-Status EQ mc_status-pending AND lv_status EQ mc_status-completed.
** Set authorizations
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        lv_wrong_status = lv_status.
* Customize error messages
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = NEW zcl_incident_messages_nc( textid = zcl_incident_messages_nc=>status_invalid
                                                            status = lv_wrong_status
                                                            severity = if_abap_behv_message=>severity-error )
                        %state_area = 'VALIDATE_COMPONENT'
                         ) TO reported-incident.
        lv_error = abap_true.
        EXIT.
      ENDIF.

      APPEND VALUE #( %tky = <incident>-%tky
                      ChangedDate = cl_abap_context_info=>get_system_date( )
                      Status = lv_status ) TO lt_updated_root_entity.

** Get Text
      lv_text = keys[ KEY id %tky = <incident>-%tky ]-%param-text.

      lv_max_his_id = get_history_index(
                  IMPORTING
                    ev_incuuid = <incident>-IncUUID ).

      IF lv_max_his_id IS INITIAL.
        ls_incident_history-his_id = 1.
      ELSE.
        ls_incident_history-his_id = lv_max_his_id + 1.
      ENDIF.

      ls_incident_history-new_status = lv_status.
      ls_incident_history-text = lv_text.

      TRY.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lo_error).
          lv_exception = lo_error->get_text(  ).
      ENDTRY.

      IF ls_incident_history-his_id IS NOT INITIAL.
*
        APPEND VALUE #( %tky = <incident>-%tky
                        %target = VALUE #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              PreviousStatus = <incident>-Status
                                              NewStatus = ls_incident_history-new_status
                                              Text = ls_incident_history-text ) )
                                               ) TO lt_association_entity.
      ENDIF.
    ENDLOOP.

    UNASSIGN <incident>.

    CHECK lv_error IS INITIAL.

    MODIFY ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
    ENTITY Incident
    UPDATE  FIELDS ( ChangedDate
                     Status )
    WITH lt_updated_root_entity.

    FREE incidents. " Free entries in incidents

    MODIFY ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
     ENTITY Incident
     CREATE BY \_History FIELDS ( HisUUID
                                  IncUUID
                                  HisID
                                  PreviousStatus
                                  NewStatus
                                  Text )
        AUTO FILL CID
        WITH lt_association_entity
     MAPPED mapped
     FAILED failed
     REPORTED reported.

    READ ENTITIES OF zr_dt_inct_nc IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT incidents
    FAILED failed.

    result = VALUE #( FOR incident IN incidents ( %tky = incident-%tky
                                                  %param = incident ) ).
  ENDMETHOD.

ENDCLASS.
