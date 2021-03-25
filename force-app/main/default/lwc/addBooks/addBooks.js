import { LightningElement, api, wire } from 'lwc';
import addBooks from '@salesforce/apex/BookController.addBooks';
import getUserId from '@salesforce/apex/BookController.getUserId';

export default class AddBooks extends LightningElement {
    addSuccessful;
    quantity;
    error;
    @api recordId;
    currentUser;

    handleChange(event) {
        event.target.value = Math.floor(Math.abs(event.target.value));
        this.quantity = event.target.value;
    }

    createRecords() {
        this.addSuccessful = undefined;
        addBooks({ bookId: this.recordId, quantity: this.quantity })
            .then(() => {
                this.addSuccessful = `Successfully added ${this.quantity} copies`;
                this.error = undefined;
            }).catch((error) => {
                this.addSuccessful = undefined;
                this.error = error.body.message;
                console.log(error);
            });
    }

    @wire(getUserId)
    wireId(result) {
        this.currentUser = result.data;
        console.log(this.currentUser);
    }
}