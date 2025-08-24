@EndUserText.label: 'Change Status'
define abstract entity zdd_change_status_param_nc
{
  @Consumption.valueHelpDefinition: [ {
      entity.name: 'zdd_status_vh_nc',
      entity.element: 'StatusCode',
      useForValidation: true
    } ]
  status : zde_status_nc;

}
