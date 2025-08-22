@Metadata.allowExtensions: true
@EndUserText.label: 'Consumption view Incident'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_DT_INCT_NC
  provider contract transactional_query
  as projection on ZR_DT_INCT_NC
{
  key IncUUID,
      IncidentID,
      Title,
      Description,
      Status,
      Priority,
      CreationDate,
      ChangedDate,
      @Semantics: {
        user.createdBy: true
      }
      LocalCreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      LocalCreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LocalLastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      
       _History : redirected to composition child ZC_DT_INCT_H_NC
}
