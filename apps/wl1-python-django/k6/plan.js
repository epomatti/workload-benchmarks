import http from 'k6/http';
import { sleep } from 'k6';

export default function () {

  // const server = "https://app-benchmark999.azurewebsites.net";
  const server = "http://localhost:8000";

  const ownerBody = {
    "name": "John",
    "age": 16,
    "birthday": "2000-01-05"
  }

  const owner = http.post(`${server}/api/owners/`, ownerBody);
  const ownerObj = JSON.parse(owner.body);
  const res1 = http.get(`${server}/api/owners/${ownerObj.id}/`);

  const petBody = {
    "name": "Linda",
    "age": 10,
    "type": "dog",
    "breed": "fox",
    "owner": ownerObj.id
  }

  const pet = http.post(`${server}/api/pets/`, petBody);
  const petObj = JSON.parse(pet.body);

  http.get(`${server}/api/pets/${petObj.id}/`);

  sleep(1);

}