@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'History'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_DT_INCT_H_NC
  as projection on zdd_inct_h_nc
{
  key HisUUID,
  key IncUUID,
      HisID,
      PreviousStatus,
      NewStatus,
      Text,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Incident : redirected to parent ZC_DT_INCT_NC
}
