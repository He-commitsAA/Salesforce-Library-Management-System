import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Book__c.Name',
    'Book__c.Author__c',
    'Book__c.ISBN__c'
];

export default class BookInfo extends LightningElement {
    @api recordId;

    bookInfo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    getBookInfo(result) {
        console.log(result);
        if (result.data) {
            const bookFields = result.data.fields;
            var url = `https://www.googleapis.com/books/v1/volumes?q=`;
            if (bookFields.ISBN__c.value) {
                url += `isbn:${bookFields.ISBN__c.value}`;
            } else if (bookFields.Name.value) {
                url += `intitle:${bookFields.Name.value}`;
                if (bookFields.Author__c.value) {
                    url += `+inauthor:${bookFields.Author__c.value}`;
                }
            }
            fetch(url)
                .then(response => response.json())
                .then(data => this.bookInfo = data.items[0]);
        }
    }

    get authors() {
        return this.bookInfo.volumeInfo.authors.join(', ');
    }

    get orderLinks() {
        const isbn = this.bookInfo.volumeInfo.industryIdentifiers[0].identifier;
        return [
            {
                name: 'Barnes & Noble',
                url: `https://www.barnesandnoble.com/w/_/_?ean=${isbn}`
            },
            {
                name: 'Amazon',
                url: `http://www.amazon.com/gp/search?index=books&linkCode=qs&keywords=${isbn}`
            },
            {
                name: 'Books-A-Million',
                url: `http://www.booksamillion.com/product/${isbn}`
            }
        ];
    }
}