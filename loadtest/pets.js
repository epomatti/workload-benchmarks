import http from 'k6/http';
import { sleep } from 'k6';

export default function () {

  const server = __ENV.HOST;

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  // Create Owner
  const ownerBody = {
    "name": "John",
    "birthday": "2000-01-05"
  }
  const ownerPayload = JSON.stringify(ownerBody);
  const owner = http.post(`${server}/api/owners/`, ownerPayload, params);
  const ownerObj = JSON.parse(owner.body);


  const res1 = http.get(`${server}/api/owners/${ownerObj.id}/`, params);

  const petBody = {
    "name": "Linda",
    "age": 10,
    "type": "dog",
    "breed": "fox",
    "owner": ownerObj.id
  }

  const petPayload = JSON.stringify(petBody);
  const pet = http.post(`${server}/api/pets/`, petPayload, params);
  const petObj = JSON.parse(pet.body);
  http.get(`${server}/api/pets/${petObj.id}/`, params);

  sleep(1);

}