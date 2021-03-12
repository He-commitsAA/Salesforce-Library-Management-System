import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkoutBook from '@salesforce/apex/BookController.checkoutBook';

export default class CheckoutBook extends LightningElement {
    @track bookNo;
    @track cardNo;

    message;
    error;

    handleChange(event) {
        if (event.target.name === 'bookNo') {
            this.bookNo = event.target.value;
        } else if (event.target.name === 'cardNo') {
            this.cardNo = event.target.value;
        }
    }

    handleClick(event) {
        event.target.disabled = true;
        this.message = undefined;
        this.error = undefined;

        var toast;

        checkoutBook({bookNo: this.bookNo, cardNo: this.cardNo})
            .then(result => toast = new ShowToastEvent({
                title: 'Checkout Successful',
                message: result,
                variant: 'success'
            }))
            .error(error => toast = new ShowToastEvent({
                title: 'Checkout Failed',
                message: error,
                variant: 'error'
            }));
        
        this.dispatchEvent(toast);
        event.target.disabled = false;
    }
}