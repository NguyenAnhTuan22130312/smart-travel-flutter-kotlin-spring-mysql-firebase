import apiPublic from "./ApiPublic";
import api from "./AxiosAuthAPI"

export const getAllDestinations  = async ()=>{
    const response = await apiPublic.get('/destination/destination-all');
    return response.data;
}
export const create  = async (dataToSubmit)=>{
    const response = await api.post(`/destination`,dataToSubmit,{
             headers: {
      "Content-Type": "multipart/form-data",
    },
    });
    return response.data;
} 
export const update  = async (editingId, dataToSubmit)=>{
    const response = await api.put(`/destination/${editingId}`,dataToSubmit, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
    });
    console.log(response.data)
    return response.data;
} 

export const deleteDestination = async (id) => {
  try {
    const response = await api.delete(
      `/destination/${id}`
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};

export const deleteDestinationImage = async (destinationId, imageId) => {
  try {
    const response = await api.delete(
      `/destination/${destinationId}/${imageId}/images`
    );
    return response.data;
  } catch (error) {
    throw error;
  }
};
