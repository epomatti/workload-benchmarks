import http from 'k6/http';
import { sleep } from 'k6';

export default function () {

  const ownerBody = {
    "name": "John",
    "age": 16,
    "birthday": "2000-01-05"
  }

  const owner = http.post("https://app-workloadbenchmark-999.azurewebsites.net/api/owners/", ownerBody);
  const ownerObj = JSON.parse(owner.body);
  http.get(`https://app-workloadbenchmark-999.azurewebsites.net/api/owners/${ownerObj.id}`);
  console.log(ownerObj.id)

  sleep(1);
  
  console.log(ownerObj.id)
  const petBody = {
    "name": "Linda",
    "age": 10,
    "type": "dog",
    "breed": "fox",
    "owner": ownerObj.id
  }
  
  const pet = http.post("https://app-workloadbenchmark-999.azurewebsites.net/api/pets/", petBody);
  console.log(pet.body)
  const petObj = JSON.parse(pet.body);
  console.log(petObj)

  http.get(`https://app-workloadbenchmark-999.azurewebsites.net/api/pets/${petObj.id}`);

  sleep(1);
}