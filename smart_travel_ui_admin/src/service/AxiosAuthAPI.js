import axios from "axios";
import { toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import apiPublic from "./ApiPublic";
import axiosInstance from "./AxiosInstance";
const api = axiosInstance;

// Biến để kiểm soát refresh token
let isRefreshing = false;
let refreshPromise = null;

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Chỉ xử lý lỗi 401 và chưa retry
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      if (!isRefreshing) {
        isRefreshing = true;
        refreshPromise = apiPublic
          .post("/auth/refresh", {})
          .then((res) => {
            const newToken = res.data.data.token;
            // Cập nhật token cho tất cả các request sau
            api.defaults.headers.common["Authorization"] = `Bearer ${newToken}`;
            localStorage.setItem("token", newToken); // Tùy chọn
            return newToken;
          })
          .catch((err) => {
            localStorage.removeItem("token");
            toast.info("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
           })
          .finally(() => {
            isRefreshing = false;
            refreshPromise = null;
          });
      }

      // Chờ token mới và retry request
      try {
        const newToken = await refreshPromise;
        originalRequest.headers["Authorization"] = `Bearer ${newToken}`;

        return api(originalRequest);
      } catch (err) {
        return Promise.reject(err);
      }
    }

    return Promise.reject(error);
  }
);

export default api;