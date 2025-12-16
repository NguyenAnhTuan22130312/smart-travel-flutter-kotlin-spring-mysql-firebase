package com.example.smart_travel_BE.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;


@Service
@RequiredArgsConstructor
public class CloudinaryService {
    private final Cloudinary cloudinary;

    public String uploadFile(MultipartFile file, String folder) throws IOException {

            Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap(
                    "folder", folder, // Ví dụ: destinations, hotels, tours, reviews
                    "upload_preset", "travel_app"
            ));
            // Lấy URL công khai
            return uploadResult.get("secure_url").toString();
    }

    public void deleteFile(String imageUrl) {
        try {
            String publicId = extractPublicIdFromUrl(imageUrl);
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    private String extractPublicIdFromUrl(String imageUrl) {
        try {
            // Tách sau "upload/"
            String[] parts = imageUrl.split("/upload/");
            if (parts.length < 2) return null;

            String path = parts[1]; // v1763284960/destinations/nkkqgqlcmokfafk1rpvm.jpg

            // Bỏ phần version v...
            if (path.startsWith("v")) {
                path = path.substring(path.indexOf("/") + 1); // => destinations/nkkqgqlcmokfafk1rpvm.jpg
            }

            // Bỏ extension (.jpg/.png...)
            int lastDot = path.lastIndexOf(".");
            if (lastDot != -1) {
                path = path.substring(0, lastDot);
            }

            return path; // => destinations/nkkqgqlcmokfafk1rpvm
        } catch (Exception e) {
            return null;
        }
    }

    //Check xem ảnh có còn tồn tại trên Cloudinary không
    public boolean checkFileExists(String imageUrl) {
        try {
            String publicId = extractPublicIdFromUrl(imageUrl);
            if (publicId == null) return false;

            // Gọi API resource
            Map result = cloudinary.api().resource(publicId, ObjectUtils.emptyMap());

            return result != null && result.get("url") != null;

        } catch (Exception e) {
            return false;
        }
    }
}