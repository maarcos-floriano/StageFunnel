import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchDevelopers from '@salesforce/apex/DeveloperAllocationController.fetchDevelopers';
import allocateDevelopers from '@salesforce/apex/DeveloperAllocationController.allocateDevelopers';
export default class DeveloperAllocation extends LightningElement {
  @api recordId;
  tecnologia = '';
  options = [
    { label: 'Salesforce', value: 'Salesforce' },
    { label: 'SAP', value: 'SAP' },
    { label: 'JavaScript', value: 'JavaScript' },
    { label: 'C#', value: 'C#' }
  ];
  developers;
  devOptions = [];
  selectedDeveloperIds = [];

  handleTecnologiaChange(event) {
    this.tecnologia = event.detail.value;
    fetchDevelopers({ tecnologia: this.tecnologia })
      .then(result => {
        this.developers = result;

        if (!this.developers || this.developers.length === 0) {
          this.devOptions = [];
          return;
        }

        this.devOptions = this.developers.map(d => ({ label: d.Name + ' (' + d.Especialidade__c + ')', value: d.Id }));
      })
      .catch(error => {
        this.developers = undefined;
        this.devOptions = [];
        const evt = new ShowToastEvent({ title: 'Erro', message: error.body ? error.body.message : error.message, variant: 'error' });
        this.dispatchEvent(evt);
      });
  }

  handleSelect(event) {
    this.selectedDeveloperIds = event.detail.value;
  }

  handleAllocate() {
    allocateDevelopers({ opportunityId: this.recordId, developerIds: this.selectedDeveloperIds, startDate: null, endDate: null })
      .then(() => {
        const evt = new ShowToastEvent({ title: 'Sucesso', message: 'Developers alocados', variant: 'success' });
        this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({ title: 'Erro', message: 'Developers não alocados: ' + (error.body ? error.body.message : error.message), variant: 'error' });
        this.dispatchEvent(evt);
      });
  }
}