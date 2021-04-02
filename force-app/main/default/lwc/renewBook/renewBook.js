import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCheckedOutBooks from '@salesforce/apex/BookController.getCheckedOutBooks';
import getLoans from '@salesforce/apex/BookController.getLoans';
import getBookList from '@salesforce/apex/BookController.getBookList';
import getBorrowers from '@salesforce/apex/BookController.getBorrowers';
import renewLoan from '@salesforce/apex/BookController.renewLoan';

export default class RenewBook extends LightningElement {
    @track loans;
    allLoans;
    copies;
    allBooks;
    borrowers; //todo: make button smaller and icon centered. add toast on renewal

    handleChange(event) {
        if (this.allLoans) {
            let searchQuery = event.target.value;
            //change shown loans to give best match to query by copy#, title, or borrower
            this.loans = [];
            for (let i in this.allLoans) {
                let l = this.allLoans[i];
                if (l.Title.toLowerCase().includes(searchQuery.toLowerCase()) || l.Serial.toLowerCase().includes(searchQuery.toLowerCase()) || l.Member.toLowerCase().includes(searchQuery.toLowerCase())) {
                    if (l !== undefined)
                        this.loans.push(l);
                }
            }
        }
        else {
            this.loans = undefined;
        }
    }

    renew(event) {
        //renew the book
        let loanId = event.target.name;
        renewLoan({ loanId: loanId })
            .then(extendedDate => {
                for (let i in this.allLoans) {
                    let loan = this.allLoans[i];
                    if (loan.Id === loanId) {
                        this.allLoans[i].Due__c = extendedDate;
                        break;
                    }
                }
                for (let i in this.loans) {
                    let loan = this.loans[i];
                    if (loan.Id === loanId) {
                        this.loans[i].Due__c = extendedDate;
                        break;
                    }
                }
                this.loans = [...this.loans];
                let toast = new ShowToastEvent({
                    title: `Due date set to ${extendedDate}`,
                    message: 'Renew successful',
                    variant: 'success'
                });
                this.dispatchEvent(toast);
                
            }).catch(error => {const toast = new ShowToastEvent({
                title: 'Renew Failed',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toast);}
            )
    }

    @wire(getBookList)
    wireAllBooks(result) {
        if (result) {
            this.allBooks = new Map();
            for (let i in result.data) {
                let book = result.data[i];
                this.allBooks.set(book.Id, book);
            }
        }
        else {
            this.allBooks = undefined;
        }
    }

    @wire(getCheckedOutBooks)
    wireCopies(result) {
        if (result) {
            this.copies = new Map();
            for (let i in result.data) {
                let copy = result.data[i];
                this.copies.set(copy.Id, copy);
            }
        }
        else {
            this.copies = undefined;
        }
    }

    @wire(getBorrowers)
    wireBorrowers(result) {
        if (result) {
            this.borrowers = new Map();
            for (let i in result.data) {
                let bor = result.data[i];
                this.borrowers.set(bor.Id, bor);
            }
        }
        else {
            this.borrowers = undefined;
        }
    }

    @wire(getLoans)
    wireLoans(result) {
        if (result) {
            this.allLoans = [];
            for (let i in result.data) {
                let loan = result.data[i];
                let newLoan = {};
                Object.assign(newLoan, loan); //copy the entire list to allow for edits
                let copy = this.copies.get(loan.Book_Copy__c);
                try {
                    newLoan.Serial = copy.Name;
                    newLoan.Title = this.allBooks.get(copy.Book__c).Name;
                    newLoan.Member = this.borrowers.get(loan.Borrower__c).Name;
                    this.allLoans.push(newLoan);
                }
                catch (e) {
                    continue;
                }
            }
        }
        else {
            this.allLoans = undefined;
        }
    }
}