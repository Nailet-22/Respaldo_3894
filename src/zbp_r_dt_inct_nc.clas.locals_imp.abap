CLASS LHC_ZR_DT_INCT_NC DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Incident
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

          METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
            IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.
ENDCLASS.

CLASS LHC_ZR_DT_INCT_NC IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
