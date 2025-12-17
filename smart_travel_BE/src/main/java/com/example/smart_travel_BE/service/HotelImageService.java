package com.example.smart_travel_BE.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.HotelImage;
import com.example.smart_travel_BE.repository.HotelImageRepository;
import com.example.smart_travel_BE.repository.HotelRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class HotelImageService {

    private final Cloudinary cloudinary;
    private final HotelRepository hotelRepository;
    private final HotelImageRepository hotelImageRepository;

    //  Upload nhiều file
    @Transactional
    public List<HotelImage> uploadMultiple(Long hotelId, List<MultipartFile> files) throws IOException {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Hotel not found"));

        int order = hotelImageRepository.findByHotelIdOrderByDisplayOrderAsc(hotelId).size();

        List<HotelImage> saved = new java.util.ArrayList<>();

        for (MultipartFile file : files) {
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "hotels/" + hotelId,
                            "resource_type", "auto"
                    ));

            HotelImage img = new HotelImage();
            img.setHotel(hotel);
            img.setImageUrl(uploadResult.get("secure_url").toString());
            img.setIsPrimary(false);
            img.setDisplayOrder(order++);

            saved.add(hotelImageRepository.save(img));
        }

        return saved;
    }


    public List<HotelImage> getImagesByHotel(Long hotelId) {
        return hotelImageRepository.findByHotelIdOrderByDisplayOrderAsc(hotelId);
    }

    @Transactional
    public void deleteImage(Long imageId) {
        hotelImageRepository.deleteById(imageId);
    }
}