import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

export function getUsers() {
  const data = new SharedArray('Users', function () {
    const fileContent = open(__ENV.FILEPATH);
    const fileExtension = __ENV.FILEPATH.split('.').pop();

    if (fileExtension === 'csv') {
        return papaparse.parse(fileContent, { header: true }).data;
    } else if (fileExtension === 'json') {
        return JSON.parse(fileContent).users;
    } else {
        throw new Error('Unsupported file format');
    }
  });
  return data;
}
