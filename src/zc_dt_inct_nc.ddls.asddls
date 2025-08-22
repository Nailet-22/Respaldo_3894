@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZDTINCT_NC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_DT_INCT_NC
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_DT_INCT_NC
  association [1..1] to ZR_DT_INCT_NC as _BaseEntity on $projection.INCUUID = _BaseEntity.INCUUID
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
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}
