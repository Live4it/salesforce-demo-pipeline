import { LightningElement, api } from 'lwc';
import processVipStatus from '@salesforce/apex/AccountController.processVipStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';

export default class VipButton extends NavigationMixin(LightningElement) {
    @api recordId;

    async handleUpdate() {
        try {
            await processVipStatus({ accountId: this.recordId });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succes',
                    message: 'Account geëvalueerd!',
                    variant: 'success'
                })
            );
            // Refresh de pagina om de nieuwe omschrijving te zien
            //eval("$A.get('e.force:refreshView').fire();"); 
            this.dispatchEvent(new RefreshEvent());
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fout',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}
