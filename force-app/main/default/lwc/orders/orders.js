import { LightningElement, api, track } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class Orders extends LightningElement {

    @api recordId;
    @track sumOrdersOfCurrentAccount;
    @track hasOrders = false;

    connectedCallback() {
        this.fetchSumOrders();
    }

    fetchSumOrders() {
        getSumOrdersByAccount({ accountId: this.recordId })
            .then(result => {
                this.sumOrdersOfCurrentAccount = result;
                this.hasOrders = result != null && result > 0;
            })
            .catch(error => {
                console.error('Erreur : ', error);
                this.hasOrders = false;
            });
    }
}