import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_travel/domain/entities/province.dart';

class ProvinceIsPopular extends StatefulWidget {
  final ProvinceEntity provinceEntity;

  const ProvinceIsPopular(this.provinceEntity, {super.key});
  @override
  State<ProvinceIsPopular> createState() => _ProvinceIsPopularState();

}

class _ProvinceIsPopularState extends State<ProvinceIsPopular> {
  @override
  Widget build(BuildContext context) {
    return _buildProvinceIsPopular(widget.provinceEntity);

  }

  Widget _buildProvinceIsPopular(ProvinceEntity provinceEntity) {
    return GestureDetector(

      onTap: () {
        // TODO: Navigate to province destinations
        Navigator.pushNamed(context, '/province/detail', arguments: provinceEntity.id
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image placeholder
              Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child:
                    provinceEntity.imageUrl !=null  ?
                    Image.network(
                      provinceEntity.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                  ) : Image.asset("assets/images/img.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,)
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Province info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provinceEntity.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provinceEntity.destinationCount}+ địa điểm',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}