import { AuthService } from '@demo/auth-lib';
import { Component } from '@angular/core';

@Component({
  selector: 'app-flights-search',
  templateUrl: './flights-search.component.html',
})
export class FlightsSearchComponent {

  constructor(private authService: AuthService) { }

userName = this.authService.userName;

  search() {
    alert('Not implemented for this demo!');
  }

  terms() {
    alert('Not implemented for this demo!');
  }

}
