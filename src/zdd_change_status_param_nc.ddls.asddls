@EndUserText.label: 'Change Status'
define abstract entity zdd_change_status_param_nc
{
@EndUserText.label: 'Change Status'
@Consumption.valueHelpDefinition: [ {
    entity.name: 'zdd_status_vh_nc',
    entity.element: 'StatusCode',
    useForValidation: true
  } ]
    status : zde_status_nc;    
@EndUserText.label: 'Add Observation Text'
    text : zde_text_nc;
}
