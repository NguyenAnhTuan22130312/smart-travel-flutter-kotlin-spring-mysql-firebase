import axios from "axios";
import api from "./AxiosAuthAPI";
import apiPublic from "./ApiPublic";

export const loginAdmin = async(email,password)=>{

      // Gọi API backend
          const response = await api.post('/auth/login/admin', {  
    email,
    password

          });
          return response;
}

// Đăng xuất
export const logoutAdmin = async () => {
        localStorage.removeItem("token");
        const response = await apiPublic.post(`/auth/logout/admin`);
     
        return response.data;
}
