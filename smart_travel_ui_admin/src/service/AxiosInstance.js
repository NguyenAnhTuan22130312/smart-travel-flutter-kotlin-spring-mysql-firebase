import axios from "axios";

const axiosInstance = axios.create({
  baseURL: "http://localhost:8080/api/v1",
  timeout: 10000,
  headers: { "Content-Type": "application/json" },
  withCredentials: true, // cho phép gửi cookie
});


// Thêm interceptor để cập nhật token động
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers["Authorization"] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default axiosInstance;
