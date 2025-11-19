import apiPublic from "./ApiPublic";
import api from "./AxiosAuthAPI"

export const getAllProvince  = async ()=>{
    const response = await apiPublic.get('/province/all');
    return response;
} 

export const editProvince  = async (editingId, dataToSubmit)=>{
    const response = await api.put(`/province/${editingId}`,dataToSubmit, {
        headers: {
      "Content-Type": "multipart/form-data",
    },
    });
    return response;
}
export const addProvince  = async (dataToSubmit)=>{
    const response = await api.post('/province', dataToSubmit,{
    headers: {
      "Content-Type": "multipart/form-data",
    },
    });
    return response;
} 
export const deleteProvince  = async (id)=>{
    const response = await api.delete(`/province/${id}`, );
    return response;
}  