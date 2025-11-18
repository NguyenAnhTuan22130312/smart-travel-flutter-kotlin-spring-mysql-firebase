import axios from "axios";

const apiPublic = axios.create({
    baseURL: 'http://localhost:8080/api/v1',
    timeout:10000,
    headers: {
    'Content-Type': 'application/json',
 },
 withCredentials: true, // cho phép gửi cookie

})

export default apiPublic ;