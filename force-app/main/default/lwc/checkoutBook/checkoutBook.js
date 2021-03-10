import { LightningElement, track } from 'lwc';
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

        checkoutBook({bookNo: this.bookNo, cardNo: this.cardNo})
            .then(result => this.message = result)
            .error(error => this.error = error);

        event.target.disabled = false;
    }
}