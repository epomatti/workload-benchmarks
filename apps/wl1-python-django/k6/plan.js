import http from 'k6/http';
import { sleep } from 'k6';

export default function () {

  const server = "app-benchmark999.azurewebsites.net";

  const ownerBody = {
    "name": "John",
    "age": 16,
    "birthday": "2000-01-05"
  }

  const owner = http.post(`https://${server}/api/owners/`, ownerBody);
  const ownerObj = JSON.parse(owner.body);
  const res1 = http.get(`https://${server}/api/owners/${ownerObj.id}/`);

  const petBody = {
    "name": "Linda",
    "age": 10,
    "type": "dog",
    "breed": "fox",
    "owner": ownerObj.id
  }

  const pet = http.post(`https://${server}/api/pets/`, petBody);
  const petObj = JSON.parse(pet.body);

  http.get(`https://${server}/api/pets/${petObj.id}/`);

  sleep(1);

}